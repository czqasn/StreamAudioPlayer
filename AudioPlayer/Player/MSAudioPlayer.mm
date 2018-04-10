//
//  AudioPlayer.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSAudioPlayer.h"
#import "FileReader.h"
#import "MSAudioDecoder.h"
#import "MSAudioQueueManager.h"
#import "MSAudioDataBufferManager.h"
#import "MSAudioInfomation.h"
#import "MSAudioFFMpegDecoder.h"
#import "MSLocalFileAVIODataProvider.h"

@interface MSAudioPlayer () <MSAudioDecoderDelegate,FileReaderDelegate,MSAudioDataBufferManagerDelegate,MSAudioFFMpegDecoderDelegate>
@property (nonatomic, strong)FileReader *fileReader ;
@property (nonatomic, strong)MSAudioDecoder  *audioDecoder ;
@property (nonatomic, strong)MSAudioQueueManager *audioQueueManager ;
@property (nonatomic, strong)MSAudioDataBufferManager *bufferManager ;
@property (nonatomic, strong)MSAudioFFMpegDecoder *avioParser ;
@end
@implementation MSAudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fileReader = [[FileReader alloc] init] ;
        self.fileReader.delegate = self ;
        
        //解码
        self.audioDecoder = [[MSAudioDecoder alloc] init] ;
        self.audioDecoder.delegate = self ;
        
        self.avioParser = [[MSAudioFFMpegDecoder alloc] initWithDataProvider:[[MSLocalFileAVIODataProvider alloc] init]] ;
        self.avioParser.delegate = self ;
        
    }
    return self;
}

- (void)play {
//    [self.fileReader startReadData] ;
    [self.avioParser startDecode] ;
   
}



#pragma mark - FileReaderDelegate 

- (void)readData:(NSData *)data {
    
    [self.audioDecoder decodeData:data] ;
}


#pragma mark - audioDecoderDelegate

- (void)decodeHeaderComplete {
    
    //缓存
    self.bufferManager = [[MSAudioDataBufferManager alloc] init] ;
    self.bufferManager.delegate = self ;
    //设置最小缓存区为 1 秒
    _bufferManager.minBufferSize = MSAudioPlayerCacheSize ;
    
    //设置最大缓存区为 20 秒
    _bufferManager.maxBufferSize = MSAudioPlayerCacheSize * 2;
    
   
   
}

- (void)hasEnoughBufferToPlay {
    
    _audioQueueManager = [[MSAudioQueueManager alloc] initWithBuffer:self.bufferManager] ;
}

- (void)decodeHeader {
    [self decodeHeaderComplete] ;
}
- (void)decodeAudio:(struct MSAudioDataModel *)packets count:(int)count{
    
    for(int i = 0 ; i < count ; i ++)
    {
        MSAudioDataModel model = (MSAudioDataModel )packets[i];
        [self.bufferManager pushDecodedData:model] ;
    }
    free(packets) ;
}

#pragma mark - Buffer 

- (void)waitingForMoreBuffer {
    _pause = YES ;
    [self.audioQueueManager pause] ;
}
- (void)hasEnoughBuffer {
    _pause = NO ;
    [self.audioQueueManager resume] ;
}


@end
