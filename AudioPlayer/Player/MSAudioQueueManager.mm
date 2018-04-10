//
//  MSAudioQueueManager.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSAudioQueueManager.h"
#import <vector>
#import "MSDefs.h"


using namespace std ;

void MSAudioQueueOutputCallback(void * __nullable       inUserData,
                                AudioQueueRef           inAQ,
                                AudioQueueBufferRef     inBuffer)
{
    MSAudioQueueManager * SELF = (__bridge MSAudioQueueManager *)inUserData ;
    [SELF qudioQueueOutputCallback:inBuffer] ;
}

@interface MSAudioQueueManager ()
@property (nonatomic, strong)MSAudioDataBufferManager *buffer ;
@property (nonatomic, assign)AudioStreamBasicDescription stresmBasicDescription ;
@end
@implementation MSAudioQueueManager
{
    AudioQueueRef _msAudioQueue ;/*音频播放队列*/
    CFMutableArrayRef _msUsableAudioQueueBufferArray ;/*可用的,音频播放队列buffer pool*/
    CFMutableArrayRef _msAllAudioQueueBufferArray ;/*用来保存buffer的引用*/
    NSCondition *_msAudioQueuePlayLock ;/*音频队列锁*/
}

- (void)dealloc
{
    //清理_msUsableAudioQueueBufferArray
    CFArrayRemoveAllValues(_msUsableAudioQueueBufferArray) ;
    CFAllocatorDeallocate(CFAllocatorGetDefault(), _msUsableAudioQueueBufferArray) ;
    CFRelease(_msUsableAudioQueueBufferArray) ;
    
    //清理分配的AudioQueueBufferRef
    for(int i = 0 ; i < CFArrayGetCount(_msAllAudioQueueBufferArray) ; i ++) {
        AudioQueueBufferRef aqb = (AudioQueueBufferRef)CFArrayGetValueAtIndex(_msAllAudioQueueBufferArray, i) ;
        AudioQueueFreeBuffer(_msAudioQueue, aqb) ;
    }
    
    //清理_msAllAudioQueueBufferArray
    CFArrayRemoveAllValues(_msAllAudioQueueBufferArray) ;
    CFAllocatorDeallocate(CFAllocatorGetDefault(), _msAllAudioQueueBufferArray) ;
    CFRelease(_msAllAudioQueueBufferArray) ;
    
    //清理_msAudioQueue
    AudioQueueDispose(_msAudioQueue, YES) ;
    
}

- (instancetype)initWithBuffer:(MSAudioDataBufferManager *)buffer
{
    self = [super init];
    if (self) {
        _buffer = buffer ;
        _stresmBasicDescription = [self defaultStreamBasicDescription] ;
        _inBufferByteSize = MSAudioPlayerCacheSize;
        _msAudioQueuePlayLock = [[NSCondition alloc] init] ;
        [self createAudioQueue] ;
    }
    return self;
}

- (AudioStreamBasicDescription)defaultStreamBasicDescription {
    
    AudioStreamBasicDescription format ;
    format.mSampleRate = MSAudioPlayerSampleRate ;
    format.mBitsPerChannel = MSAudioPlayerBitsPerChannel ;
    format.mFramesPerPacket = MSAudioPlayerFramesPerPacket;
    format.mChannelsPerFrame = MSAudioPlayerChannelsPerFrame;
    format.mFormatID = kAudioFormatLinearPCM;//778924083 ;
    format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked  ;
    format.mBytesPerFrame = format.mBitsPerChannel / 8 * format.mChannelsPerFrame;
    format.mBytesPerPacket = format.mFramesPerPacket * format.mBytesPerFrame  ;
    return format ;
    
}

- (void)createAudioQueue {
    /*创建队列*/
    OSStatus status = AudioQueueNewOutput(&_stresmBasicDescription,
                        MSAudioQueueOutputCallback,
                        (__bridge void *)self,
                        NULL/*当前runloop*/,
                        NULL/*当前runloop mode*/,
                        0,
                        &_msAudioQueue) ;
    if(status != noErr) {
        //创建失败了,清除资源
        AudioQueueDispose(_msAudioQueue, YES/*立即销毁*/) ;
        _msAudioQueue = nil ;
        NSLog(@"创建播放队列失败") ;
        return ;
    }
    NSLog(@"创建队列成功") ;
    
    //创建audio queue buffer pool
    _msUsableAudioQueueBufferArray = CFArrayCreateMutable(CFAllocatorGetDefault(), 3, NULL) ;
    _msAllAudioQueueBufferArray = CFArrayCreateMutable(CFAllocatorGetDefault(), 3, NULL) ;
    for(int i = 0 ; i < 3 ; i ++) {
        AudioQueueBufferRef bufferRef = NULL ;
        AudioQueueAllocateBuffer(_msAudioQueue,_inBufferByteSize * 2, &bufferRef) ;
        CFArrayAppendValue(_msUsableAudioQueueBufferArray, bufferRef) ;
        CFArrayAppendValue(_msAllAudioQueueBufferArray, bufferRef) ;
    }

    AudioQueueStart(_msAudioQueue, NULL/*立即开始*/);
    NSLog(@"开始播放") ;
    [NSThread detachNewThreadSelector:@selector(startRead) toTarget:self withObject:nil] ;
}
- (void)startRead {
    while (1) {
        @autoreleasepool {
            
            [_msAudioQueuePlayLock lock] ;
            
            if(CFArrayGetCount(_msUsableAudioQueueBufferArray) == 0) {
                NSLog(@"等待空闲Audio Queue Buffer") ;
                [_msAudioQueuePlayLock wait] ;//等待audio queue buffer pool有可用的AudioQueueBufferRef
            }
            
            AudioQueueBufferRef audioQueueBuffer = (AudioQueueBufferRef)CFArrayGetValueAtIndex(_msUsableAudioQueueBufferArray, 0) ;//
            vector<MSAudioDataModel> tmps = [self.buffer popDecodedData:self.inBufferByteSize] ;
            
            AudioStreamPacketDescription *spds = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * tmps.size());
            SInt64 offset = 0 ;
            typedef vector<MSAudioDataModel>::iterator VIntIterator;
            VIntIterator end = tmps.end();
            int j = 0 ;
            for( VIntIterator i = tmps.begin() ; i != end ; ++i )
            {
                MSAudioDataModel model = *i ;
                spds[j] = model.packetDescription ;
                spds[j].mStartOffset = offset ;
                
                memcpy((char *)audioQueueBuffer->mAudioData + offset, model.data, model.dataLen);
                
                offset += spds[j].mDataByteSize ;
                j ++ ;
                
                
                free(model.data) ;
            }
            
            audioQueueBuffer->mAudioDataByteSize = (UInt32)offset;
            AudioQueueEnqueueBuffer(_msAudioQueue, audioQueueBuffer, (UInt32)tmps.size(),spds) ;
            free(spds) ;
            //从可用中移除
            CFArrayRemoveValueAtIndex(_msUsableAudioQueueBufferArray,0) ;
            [_msAudioQueuePlayLock unlock] ;
        }

  
    }
    
}

- (void)pause {
    AudioQueuePause(_msAudioQueue) ;
}

- (void)resume {
    
    AudioQueueStart(_msAudioQueue, NULL) ;
}

- (void)qudioQueueOutputCallback:(AudioQueueBufferRef)audioQueueRef {
    
    
    [_msAudioQueuePlayLock lock] ;
    //已经有可用的AudioQueueBufferRef
    CFArrayAppendValue(_msUsableAudioQueueBufferArray, audioQueueRef) ;
    NSLog(@"------>[%@]:清理:::%ld",[NSThread currentThread],CFArrayGetCount(_msUsableAudioQueueBufferArray)) ;
    [_msAudioQueuePlayLock signal] ;
    [_msAudioQueuePlayLock unlock] ;
}


@end
