//
//  MSDefs
//  AudioPlayer
//
//  Created by legendry on 2017/8/9.
//  Copyright © 2017年 legendry. All rights reserved.
//

#ifndef audio_pcm_model_h
#define audio_pcm_model_h

#import <AVFoundation/AVFoundation.h>

struct MSAudioDataModel{
    UInt32 dataLen ;
    void *data ;
    AudioStreamPacketDescription packetDescription ;
};


#define MSAudioPlayerSampleRate         44100
#define MSAudioPlayerBitsPerChannel     16
#define MSAudioPlayerFramesPerPacket    1
#define MSAudioPlayerChannelsPerFrame   2
#define MSAudioPlayerCacheSize          1024 * 32

#endif /* audio_pcm_model_h */
