//
//  FileReader.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/4.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "FileReader.h"



@interface FileReader ()
@property (nonatomic, strong)NSFileHandle *fileHandle ;
@property (nonatomic, assign)NSInteger fileSize ;

@property (nonatomic, assign)NSInteger loc;
@property (nonatomic, assign)NSInteger len;
@end

@implementation FileReader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loc = 0 ;
        self.len = 1024 ;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"t2" ofType:@"mp3"] ;
        self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath] ;
    }
    return self;
}

- (NSInteger)fileSize {
    if(_fileSize == 0) {
        NSInteger size = [self.fileHandle seekToEndOfFile] ;
        [self.fileHandle seekToFileOffset:0] ;
        _fileSize = size ;
        return size ;
    }
    return _fileSize ;
}

- (void)startReadData {
    
    [NSThread detachNewThreadSelector:@selector(readData) toTarget:self withObject:nil] ;
   
}

- (void)readData {
    while (self.fileSize > self.loc) {
        @autoreleasepool {
            NSInteger readLen = 0 ;
            if(self.fileSize >= self.loc + self.len) {
                readLen = self.len ;
            } else {
                readLen = self.fileSize - self.loc ;
            }
            NSData *data = [self readDataWithStartLocation:self.loc length:readLen] ;
            self.loc += readLen ;
            if(data && data.length > 0) {
                !self.delegate ? : [self.delegate readData:data] ;
            }

        }
//                [NSThread sleepForTimeInterval:0.1] ;
    }
}


- (void)readData2 {
    
        
    
}

- (NSData *)readDataWithStartLocation:(NSInteger)startLocation length:(NSInteger)length {
    [self.fileHandle seekToFileOffset:startLocation] ;
    return [self.fileHandle readDataOfLength:length] ;
}

@end
