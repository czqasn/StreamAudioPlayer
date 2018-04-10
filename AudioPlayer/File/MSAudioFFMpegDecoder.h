//
//  AVIOParaser.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/25.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDefs.h"
#import <CoreAudio/CoreAudioTypes.h>
#import "MSAVIODataProvider.h"

@protocol MSAudioFFMpegDecoderDelegate <NSObject>

/**解析到头部信息*/
- (void)decodeHeader;
/**解析到音频PCM原始数据*/
- (void)decodeAudio:(struct MSAudioDataModel *)packets count:(int)count ;

@end

@interface MSAudioFFMpegDecoder : NSObject
@property (nonatomic,weak)id<MSAudioFFMpegDecoderDelegate> delegate ;
@property (nonatomic,strong)NSFileHandle *handle ;

- (instancetype)initWithDataProvider:(id<MSAVIODataProvider>)provider ;

- (void)seek:(int)ofs;
- (int)getData:(uint8_t *)buf size:(int)buf_size ;

- (void)startDecode ;

@end
