//
//  AudioParse.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/4.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSAudioDecoder.h"
#import <AVFoundation/AVFoundation.h>
#import "MSDefs.h"


void MSAudioFileStream_PropertyListenerProc(
                                             void *							inClientData,
                                             AudioFileStreamID				inAudioFileStream,
                                             AudioFileStreamPropertyID		inPropertyID,
                                            AudioFileStreamPropertyFlags *	ioFlags) {

    MSAudioDecoder *SELF = (__bridge MSAudioDecoder  *)inClientData ;
    [SELF decodePropertyValue:inAudioFileStream
                                        inPropertyID:inPropertyID] ;
}

void MSAudioFileStream_PacketsProc(
                                    void *							inClientData,
                                    UInt32							inNumberBytes,
                                    UInt32							inNumberPackets,
                                    const void *					inInputData,
                                   AudioStreamPacketDescription	*inPacketDescriptions) {
    MSAudioDecoder  *SELF = (__bridge MSAudioDecoder  *)inClientData ;
    [SELF decodeData:inNumberBytes
            inNumberPackets:inNumberPackets
                inInputData:inInputData
       inPacketDescriptions:inPacketDescriptions] ;
}

@interface MSAudioDecoder ()<MSAudioInfomationDelegate>

@end
@implementation MSAudioDecoder
{
    AudioFileStreamID _audioFileStreamID ;
    AudioFileTypeID _audioFileTypeID ;
    MSAudioInfomation *_msAudioInformation ;/**解析头部得到的信息*/
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _audioFileTypeID = kAudioFileMP3Type ;
        _msAudioInformation = [[MSAudioInfomation alloc] init] ;
        _msAudioInformation.delegate = self ;
        [self startDecode] ;
    }
    return self;
}

- (BOOL)startDecode {
    OSStatus status = AudioFileStreamOpen((__bridge void *)self,
                        MSAudioFileStream_PropertyListenerProc,
                        MSAudioFileStream_PacketsProc,
                        _audioFileTypeID,
                        &_audioFileStreamID);
    return status == noErr ;
}

- (BOOL)decodeData:(NSData *)data {
    
    OSStatus status = AudioFileStreamParseBytes(_audioFileStreamID, (UInt32)data.length, [data bytes], 0) ;
    return status == 0 ;
    
}

#pragma mark - Parse Handle 

- (void)decodePropertyValue:(AudioFileStreamID)inAudioFileStream inPropertyID:(AudioFileStreamPropertyID)inPropertyID {
    [_msAudioInformation getPropertyValue:inAudioFileStream inPropertyID:inPropertyID] ;
    
}

- (void)decodeData:(UInt32)inNumberBytes
        inNumberPackets:(UInt32)inNumberPackets
            inInputData:(const void *)inInputData
   inPacketDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions {
    
    if(inNumberBytes == 0)
        return ;

    struct MSAudioDataModel *tmps = (struct MSAudioDataModel *)malloc(sizeof(struct MSAudioDataModel) * inNumberPackets) ;
    for(int i = 0 ; i < inNumberPackets ; i ++) {
        AudioStreamPacketDescription packetDescription = inPacketDescriptions[i] ;
        struct MSAudioDataModel model ;
        model.dataLen = packetDescription.mDataByteSize ;
        model.data = malloc(model.dataLen) ;

        memcpy(model.data, (const char *)inInputData + packetDescription.mStartOffset, packetDescription.mDataByteSize) ;
        model.packetDescription = packetDescription ;
        tmps[i] = model ;
    }

    if(self.delegate) {
        [self.delegate decodeAudio:tmps count:inNumberPackets] ;
    }
    free(tmps) ;
    
    
}

- (MSAudioInfomation *)audioInformation {
    return _msAudioInformation ;
}

#pragma mark - 

- (void)decodeHeaderComplete {
    if(self.delegate) {
        [self.delegate decodeHeaderComplete] ;
    }
}

@end
