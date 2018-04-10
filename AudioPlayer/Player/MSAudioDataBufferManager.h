//
//  MSAudioDataBufferManager.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDefs.h"
#import <vector>


@protocol MSAudioDataBufferManagerDelegate <NSObject>
/**缓存区数据不够,等待更多多数据进入*/
- (void)waitingForMoreBuffer ;
/**缓存区数据已经达到最小缓存大小*/
- (void)hasEnoughBuffer ;
/**第一次有足够的缓存可以开始启动播放队列了*/
- (void)hasEnoughBufferToPlay ;
@end

@interface MSAudioDataBufferManager : NSObject
/**最小播放缓存大小*/
@property (nonatomic, assign)UInt32 minBufferSize ;
/**最大播放缓存大小*/
@property (nonatomic, assign)UInt32 maxBufferSize ;
/**当前缓存大小*/
@property (nonatomic, assign)UInt32 bufferSize ;

@property (nonatomic, assign)id<MSAudioDataBufferManagerDelegate> delegate ;

/**把解码后的音频数据放入缓存除队列*/
- (void)pushDecodedData:(MSAudioDataModel)model ;

/**从缓存队列中获取可用数量的包*/
- (std::vector<MSAudioDataModel>)popDecodedData:(UInt32)length;

@end
