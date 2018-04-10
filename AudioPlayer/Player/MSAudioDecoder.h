//
//  MSAudioDecoder .h
//  AudioPlayer
//
//  Created by legendry on 2017/8/4.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MSAudioInfomation.h"
#import "MSDefs.h"

@protocol MSAudioDecoderDelegate <NSObject>

/**
 *  解析到音频数据
 *
 *  @param packets 音频数据
 *  @param count   音频数据包数量
 */
- (void)decodeAudio:(struct MSAudioDataModel *)packets count:(int)count ;

/**解析头部完成,即将开始解析音频数据*/
- (void)decodeHeaderComplete ;
@end

@interface MSAudioDecoder : NSObject


/**解析代理 */
@property (nonatomic, weak,readwrite)id<MSAudioDecoderDelegate> delegate ;

/**开始解码音频*/
- (BOOL)startDecode;
/**解析音频数据*/
- (BOOL)decodeData:(NSData *)data ;
/**解码头信息*/
- (void)decodePropertyValue:(AudioFileStreamID)inAudioFileStream
               inPropertyID:(AudioFileStreamPropertyID)inPropertyID ;
/**解码音频数据*/
- (void)decodeData:(UInt32)inNumberBytes
        inNumberPackets:(UInt32)inNumberPackets
            inInputData:(const void *)inInputData
   inPacketDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

/**音频文件头信息*/
- (MSAudioInfomation *)audioInformation ;

@end
