//
//  AVIOParaser.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/25.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "MSAudioFFMpegDecoder.h"

#include <stdio.h>
#include <stdlib.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#import "MSLocalFileAVIODataProvider.h"

#define AVCODEC_MAX_AUDIO_FRAME_SIZE 192000



int read_buffer(void *context, uint8_t *buf, int buf_size){
    
    MSAudioFFMpegDecoder *this = (__bridge MSAudioFFMpegDecoder *)context ;
    return [this getData:buf size:buf_size] ;
    
}

int64_t seek(void *context, int64_t offset, int whence) {
    
    MSAudioFFMpegDecoder *this = (__bridge MSAudioFFMpegDecoder *)context ;
    if(whence == 0) {
        [this seek:(int)offset] ;
    }
    return 1 ;
}

@interface MSAudioFFMpegDecoder (){
    
    int offset  ;//读取数据的起始位置
    int file_size ;//文件总大小
}
/**数据提供者*/
@property (nonatomic,strong)id<MSAVIODataProvider> dataProvider ;
@end
@implementation MSAudioFFMpegDecoder


- (instancetype)initWithDataProvider:(id<MSAVIODataProvider>)provider
{
    self = [super init];
    if (self) {
        NSParameterAssert(provider) ;
        self.dataProvider = provider ;
        file_size = (int)[self.dataProvider fileSize];
    }
    return self;
}
- (void)startDecode {
    
    
    [NSThread detachNewThreadSelector:@selector(decode) toTarget:self withObject:nil] ;
 
    

}

- (void)seek:(int)ofs {
    NSLog(@"[解码] seek:%d",ofs) ;
    offset = ofs ;
}

- (int)getData:(uint8_t *)buf size:(int)buf_size {
    
    @autoreleasepool {
        if(offset >= file_size)
            return -1 ;
        
        NSData *data = [self.dataProvider getDataWithStart:offset len:buf_size + offset > file_size ? (file_size - offset) : buf_size];
        [data getBytes:buf range:NSMakeRange(0, data.length)] ;
        offset += data.length ;
        NSLog(@"[解码]已经读取:%d",offset) ;
        if(file_size == offset) {
            NSLog(@"[解码]文件读取完成") ;
        }
        
         return (int)data.length ;
    }
   
    

}
- (void)decode {
    
    av_register_all();
    AVFormatContext* container = avformat_alloc_context();
    unsigned char *aviobuffer = (unsigned char *)av_malloc(MSAudioPlayerCacheSize);
    AVIOContext *avioContext = avio_alloc_context(aviobuffer, MSAudioPlayerCacheSize, 0, (__bridge void *)self, read_buffer, NULL, seek) ;
    
   
    container->pb = avioContext ;
    if(avformat_open_input(&container,NULL,NULL,NULL) !=0 ){
        NSLog(@"Couldn't open input stream.");
        return ;
    }
    

    
    if(avformat_find_stream_info(container, NULL)<0){
        NSLog(@"Could not find file info");
        return ;
    }
    
    
    
    int stream_id = -1;
    for(int i = 0 ; i < container->nb_streams; i++){
        if(container->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO){
            stream_id = i;
            break;
        }
    }
    if(stream_id == -1){
        NSLog(@"Could not find Audio Stream");
    }
    AVDictionary *meta = container->metadata ;
    AVDictionaryEntry *entry ;
    
    while ((entry = av_dict_get(meta, "", entry, AV_DICT_IGNORE_SUFFIX))) {
        if(entry) {
            NSLog(@"key:%s,val:%s",entry->key,entry->value) ;
        }
    }
    
    NSLog(@"时长:%.2f 秒",container->duration * 1.0f / AV_TIME_BASE) ;
    av_dump_format(container, stream_id, NULL, 0) ;


    AVCodecParameters *avcodecParams = container->streams[stream_id]->codecpar ;
    [self.delegate decodeHeader] ;
    AVCodec *codec = avcodec_find_decoder(avcodecParams->codec_id);
    AVCodecContext *_codec_context = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(_codec_context, avcodecParams) ;
    NSLog(@"找到音频解码器:%s",codec->name) ;
    if(codec==NULL){
        printf("cannot find codec!");
    }
    if(avcodec_open2(_codec_context,codec,NULL)<0){
        printf("Codec cannot be found");
    }

    AVPacket packet;
    av_init_packet(&packet);
    AVFrame *frame = av_frame_alloc() ;
    int buffer_size = AVCODEC_MAX_AUDIO_FRAME_SIZE + FF_INPUT_BUFFER_PADDING_SIZE;;
    packet.data = NULL;
    packet.size = buffer_size;

    struct SwrContext *au_convert_ctx = swr_alloc();
    au_convert_ctx = swr_alloc_set_opts(NULL,
                                        AV_CH_LAYOUT_STEREO,
                                        AV_SAMPLE_FMT_S16,
                                        avcodecParams->sample_rate,
                                        _codec_context->channel_layout,
                                        _codec_context->sample_fmt,
                                        _codec_context->sample_rate,
                                        0,
                                        NULL);
    swr_init(au_convert_ctx);
    

    
    int totalFrameCount = 0 ;
    
    while(av_read_frame(container,&packet) >= 0)
    {
        @autoreleasepool {
            if(packet.stream_index==stream_id)
            {
                
                avcodec_send_packet(_codec_context, &packet) ;
                avcodec_receive_frame(_codec_context, frame) ;

                int numberOfFrames;
                void *audioDataBuffer;
                const int buffer_size = av_samples_get_buffer_size(NULL, MSAudioPlayerChannelsPerFrame, frame->nb_samples, AV_SAMPLE_FMT_S16, 1);
                audioDataBuffer =  malloc(buffer_size) ;
                
                
                Byte * outyput_buffer[2] = {audioDataBuffer, 0};
                numberOfFrames = swr_convert(au_convert_ctx,
                                             outyput_buffer,
                                             frame->nb_samples,
                                             (const uint8_t **)frame->data,
                                             frame->nb_samples);
                
                
                if(buffer_size > 0)
                {
                    
                    struct MSAudioDataModel *tmps = (struct MSAudioDataModel *)malloc(sizeof(struct MSAudioDataModel) * 1) ;
                    AudioStreamPacketDescription packetDescription  ;
                    packetDescription.mStartOffset = 0 ;
                    packetDescription.mDataByteSize = buffer_size ;
                    packetDescription.mVariableFramesInPacket = 0 ;
                    
                    struct MSAudioDataModel model ;
                    model.dataLen = buffer_size;//packetDescription.mDataByteSize ;
                    model.data = malloc(model.dataLen) ;
                    
                    memcpy(model.data, outyput_buffer[0], buffer_size) ;

                    model.packetDescription = packetDescription ;
                    tmps[0] = model ;
                    totalFrameCount ++ ;
                    NSLog(@"[解码]解码得到数据:%d,总共数据帧:%d",buffer_size,totalFrameCount) ;
                    [self.delegate decodeAudio:tmps count:1] ;
    
                }
                free(audioDataBuffer) ;
                av_packet_unref(&packet) ;
                av_frame_unref(frame) ;
            }

        }
    }
    
    avcodec_free_context(&_codec_context) ;
    swr_free(&au_convert_ctx) ;
    av_free(frame) ;
    avformat_close_input(&container) ;

}
@end
