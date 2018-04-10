//
//  FileReader.h
//  AudioPlayer
//
//  Created by legendry on 2017/8/4.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileReaderDelegate <NSObject>
- (void)readData:(NSData *)data;
@end
@interface FileReader : NSObject

@property (nonatomic, weak)id<FileReaderDelegate> delegate ;
- (void)startReadData ;
- (NSInteger)fileSize ;
- (NSData *)readDataWithStartLocation:(NSInteger)startLocation length:(NSInteger)length ;

@end
