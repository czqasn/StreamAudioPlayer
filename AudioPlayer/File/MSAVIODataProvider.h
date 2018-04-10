//
//  MSAVIODataProvider.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/28.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSAVIODataProvider <NSObject>

- (NSData *)getDataWithStart:(int)start len:(int)len ;
- (NSUInteger)fileSize ;

@end
