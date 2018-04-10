//
//  MSAudioQueueManager.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSAudioDataBufferManager.h"
#import "MSAudioDecoder.h"
#import <AVFoundation/AVFoundation.h>

/**音频数据读取,放入AudioQueu播放*/
@interface MSAudioQueueManager : NSObject
@property (nonatomic, assign)UInt32 inBufferByteSize ;

- (instancetype)initWithBuffer:(MSAudioDataBufferManager *)buffer;

- (void)qudioQueueOutputCallback:(AudioQueueBufferRef)audioQueueRef;

- (void)pause ;

- (void)resume ;


@end
