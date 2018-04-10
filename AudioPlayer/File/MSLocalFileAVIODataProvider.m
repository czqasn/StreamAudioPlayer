//
//  MSLocalFileAVIODataProvider.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/28.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSLocalFileAVIODataProvider.h"


@interface MSLocalFileAVIODataProvider ()
{
    NSFileHandle *_fileHandle ;
    NSString *_filePath ;
}
@end
@implementation MSLocalFileAVIODataProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filePath = [[NSBundle mainBundle] pathForResource:@"t2" ofType:@"mp3"] ;
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath] ;
        
    }
    return self;
}
- (NSData *)getDataWithStart:(int)start len:(int)len {
    
    [_fileHandle seekToFileOffset:start] ;
    NSData *data = [_fileHandle readDataOfLength:len] ;
    return data ;
}
- (NSUInteger)fileSize {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil][NSFileSize] integerValue] ;
}

@end
