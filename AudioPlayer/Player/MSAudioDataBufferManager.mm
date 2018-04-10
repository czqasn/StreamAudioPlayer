//
//  MSAudioDataBufferManager.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//



#import "MSAudioDataBufferManager.h"
#import <Foundation/Foundation.h>

#import <queue>
#import <list>
using namespace std ;


@interface MSAudioDataBufferManager ()

@property (nonatomic, strong)NSCondition *minLock ;
@property (nonatomic, strong)NSCondition *maxLock ;
@property (nonatomic, assign)UInt32 totalBufferSize ;//总共读取了多少缓存
@property (nonatomic, assign)BOOL hasPlayed ;//是否已经开始播放了(启动了播放队列)
@end

@implementation MSAudioDataBufferManager
{
    queue<MSAudioDataModel> *_audioDataQueue ;
}

- (void)dealloc
{
    //清理数据
    while (!_audioDataQueue->empty()) {
        MSAudioDataModel tmp_model = (MSAudioDataModel)_audioDataQueue->front() ;
        free(tmp_model.data) ;
        _audioDataQueue->pop() ;
    }
    if(_audioDataQueue) free(_audioDataQueue) ;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minLock = [[NSCondition alloc] init] ;
        self.maxLock = [[NSCondition alloc] init] ;
        _audioDataQueue = new queue<MSAudioDataModel>();
    }
    return self;
}

- (void)pushDecodedData:(MSAudioDataModel)_model {
    
 
    
    
    [self.minLock lock] ;
    
    MSAudioDataModel model = (MSAudioDataModel)_model ;
    
    _audioDataQueue->push(model) ;
    
    self.bufferSize += (UInt32)model.dataLen ;
    self.totalBufferSize += (UInt32)model.dataLen ;
    NSLog(@"[Buffer]放入数据:%d,总共的缓存:%d,最小播放缓存:%d,已有音频包数量:%ld",self.bufferSize,self.totalBufferSize,self.minBufferSize,_audioDataQueue->size()) ;
    if(self.bufferSize >= self.minBufferSize) {
        [self.minLock signal] ;
        if(!_hasPlayed) {
            if(self.delegate) {
                [self.delegate hasEnoughBufferToPlay] ;
            }
            _hasPlayed = YES ;
        }
    }
    [self.minLock unlock] ;
   
    [_maxLock lock] ;
    if(self.bufferSize > self.maxBufferSize) {
        NSLog(@"缓存太大,等待减少...") ;
        [_maxLock wait] ;
        NSLog(@"缓存过大等待结束...") ;
    }
    [_maxLock unlock] ;
    
}

- (vector<MSAudioDataModel>)popDecodedData:(UInt32)length
{
    
    [_maxLock lock] ;
    [_maxLock signal] ;
    [_maxLock unlock] ;
    
    
    [self.minLock lock] ;
    vector<MSAudioDataModel> tmps ;
    //数据不够
    if(_audioDataQueue->size() == 0) {
        NSLog(@"等待pcm数据解析进入pcm data buffer.") ;
        if(self.delegate) {
            [self.delegate waitingForMoreBuffer] ;
        }
        [self.minLock wait] ;
        if(self.delegate) {
            [self.delegate hasEnoughBuffer] ;
        }
    }
    
    
    int canReadLen = length ;//剩余还需要读取的大小
    int totalReadLen = 0 ; //此次总共读取的大小

    
    
    
    if(self.bufferSize < length) {
        /*读取当前队列中所有可用的音频包*/
        while (!_audioDataQueue->empty()) {
            MSAudioDataModel tmp_model = (MSAudioDataModel)_audioDataQueue->front() ;
            totalReadLen += tmp_model.dataLen;
            tmps.push_back(tmp_model) ;
            _audioDataQueue->pop() ;
        }
    } else {
        /*读取给定长度上下的可用音频包*/
        while (!_audioDataQueue->empty()) {
            MSAudioDataModel tmp_model = (MSAudioDataModel)_audioDataQueue->front() ;
            totalReadLen += tmp_model.dataLen;
            canReadLen -= tmp_model.dataLen ;
            tmps.push_back(tmp_model) ;
            _audioDataQueue->pop() ;
            if(canReadLen < 0)
                break ;
        }
    }
    
    //当前缓存大小减去此次读取的大小
    self.bufferSize -= totalReadLen ;
    
    NSLog(@"[Buffer]读取数据完成:%d---已有数据:%d--%ld,读取了:%ld",length,self.bufferSize,_audioDataQueue->size(),tmps.size()) ;
    [self.minLock unlock] ;
    
   
    return tmps ;
}


@end
