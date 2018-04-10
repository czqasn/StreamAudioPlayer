//
//  AudioPlayer.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/7.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSAudioPlayer : NSObject
@property (nonatomic, assign,getter=isPause,readonly)BOOL pause ;
- (void)play ;

@end
