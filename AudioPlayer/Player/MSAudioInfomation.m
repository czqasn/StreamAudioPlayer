//
//  MSAudioInfomation.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/10.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSAudioInfomation.h"

@implementation MSAudioInfomation

- (void)getPropertyValue:(AudioFileStreamID)inAudioFileStream
            inPropertyID:(AudioFileStreamPropertyID)inPropertyID {
    /*
     kAudioFileStreamProperty_ReadyToProducePackets //准备开始
     kAudioFileStreamProperty_FileFormat
     kAudioFileStreamProperty_DataFormat
     kAudioFileStreamProperty_FormatList
     kAudioFileStreamProperty_MagicCookieData
     kAudioFileStreamProperty_AudioDataByteCount
     kAudioFileStreamProperty_AudioDataPacketCount
     kAudioFileStreamProperty_MaximumPacketSize
     kAudioFileStreamProperty_DataOffset //头部偏移量
     kAudioFileStreamProperty_ChannelLayout
     kAudioFileStreamProperty_PacketToFrame
     kAudioFileStreamProperty_FrameToPacket
     kAudioFileStreamProperty_PacketToByte
     kAudioFileStreamProperty_ByteToPacket
     kAudioFileStreamProperty_PacketTableInfo
     kAudioFileStreamProperty_PacketSizeUpperBound
     kAudioFileStreamProperty_AverageBytesPerPacket
     kAudioFileStreamProperty_BitRate
     kAudioFileStreamProperty_InfoDictionary
     */
    
    UInt32 pdSize = 0 ;
    
    
    switch (inPropertyID) {
        case kAudioFileStreamProperty_AudioDataByteCount:
        {
            pdSize = sizeof(UInt64) ;
            AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &pdSize, &_totalSize) ;
            NSLog(@"总共的数据大小:%lld",_totalSize);
            
            break;
        }
        case kAudioFileStreamProperty_DataOffset :
        {
            pdSize = sizeof(SInt64) ;
            AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &pdSize, &_headerDataOffset) ;
            NSLog(@"头部偏移量大小:%lld",_headerDataOffset);
            break ;
        }
        case kAudioFileStreamProperty_DataFormat :
        {
            pdSize = sizeof(AudioStreamBasicDescription) ;
            AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &pdSize, &_streamBasicDescription) ;
            NSLog(@"获取音频配置描述");
            break ;
        }
        case kAudioFileStreamProperty_AudioDataPacketCount :
        {
            pdSize = sizeof(UInt64) ;
            AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &pdSize, &_packetCount) ;
            NSLog(@"总共包数量:%lld",_packetCount);
            break ;
        }
        case kAudioFileStreamProperty_BitRate:
        {
            pdSize = sizeof(UInt32) ;
            AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &pdSize, &_bitRate) ;
            NSLog(@"比特率:%u,一秒KB:%u",_bitRate,_bitRate / 8 / 1024);
            break ;
        }
        case kAudioFileStreamProperty_ReadyToProducePackets:
        {
            _duration = (_totalSize - _headerDataOffset) / (_bitRate / 8 ) ;
            NSLog(@"时长:%f",self.duration) ;
            if(self.delegate) {
                [self.delegate decodeHeaderComplete] ;
            }
            break ;
        }
        default:
            break;
    }

}

@end
