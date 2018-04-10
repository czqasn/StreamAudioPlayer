//
//  MSAudioInfomation.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/10.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MSAudioInfomationDelegate <NSObject>

/**头部信息解析完成*/
- (void)decodeHeaderComplete;

@end

@interface MSAudioInfomation : NSObject

/**头信息偏移量*/
@property (nonatomic, assign,readonly)SInt64 headerDataOffset ;
/**文件数据总大小*/
@property (nonatomic, assign,readonly)UInt64 totalSize ;
/**音频描述文件*/
@property (nonatomic, assign,readonly)AudioStreamBasicDescription streamBasicDescription ;
/**比特率*/
@property (nonatomic, assign,readonly)UInt32 bitRate;
/**总共包数量*/
@property (nonatomic, assign,readonly)UInt64 packetCount ;
/**时长*/
@property (nonatomic, assign,readonly)CGFloat duration;
/**音频解析代理*/
@property (nonatomic, weak)id<MSAudioInfomationDelegate> delegate ;

/**获取对应属性的值*/
- (void)getPropertyValue:(AudioFileStreamID)inAudioFileStream
            inPropertyID:(AudioFileStreamPropertyID)inPropertyID ;

@end
