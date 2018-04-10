//
//  ViewController.m
//  AudioPlayer
//
//  Created by legendry on 2017/8/4.
//  Copyright © 2017年 legendry. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MSAudioPlayer.h"

#include <stdio.h>
#include <stdlib.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#import "MSAudioFFMpegDecoder.h"



#define AVCODEC_MAX_AUDIO_FRAME_SIZE 192000

@interface ViewController ()
@property (nonatomic, strong)MSAudioPlayer *player ;
@property (nonatomic,strong)MSAudioFFMpegDecoder *avioParser ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.player = [[MSAudioPlayer alloc] init] ;
  
    
    
    
}

- (void)playAudio {
    AVAudioSession *session = [AVAudioSession sharedInstance] ;
    NSError *error ;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error] ;
    [session setActive:YES error:&error] ;
    [self.player play] ;
    
//    [self decode] ;

//    _avioParser = [[AVIOParaser alloc] init] ;
//    [_avioParser parse] ;
}

- (void)decode {
    
    /*
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"t2" ofType:@"mp3"] ;
    const char *filename = filePath.UTF8String ;
    av_register_all();  //注册所有可解码类型
    AVFormatContext *pInFmtCtx=NULL;    //文件格式
    AVCodecContext *pInCodecCtx=NULL;   //编码格式
    AVCodecParameters *codeParams ;
    
    
    if (avformat_open_input(&pInFmtCtx, filename, NULL, NULL) != 0) {//获取文件格式
        printf("av_open_input_file error\n");
    }
    
    
    if (avformat_find_stream_info(pInFmtCtx,NULL) < 0)  //获取文件内音视频流的信息
        printf("av_find_stream_info error\n");
    
    NSLog(@"找到音频流信息") ;
    
   
    unsigned int j;
    // Find the first audio stream
    
    int audioStream = -1;
    for (j=0; j<pInFmtCtx->nb_streams; j++)   //找到音频对应的stream
    {
        if (pInFmtCtx->streams[j]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO)
        {
            audioStream = j;
            break;
        }
    }
    if (audioStream == -1)
    {
        printf("input file has no audio stream\n");
        return ; // Didn't find a audio stream
    }
    printf("audio stream num: %d\n",audioStream);
   
//    pInCodecCtx = pInFmtCtx->streams[audioStream]->codec; //音频的编码上下文
    codeParams = pInFmtCtx->streams[audioStream]->codecpar ;
    AVCodec *pInCodec = NULL;
    
    pInCodec = avcodec_find_decoder(codeParams->codec_id); //根据编码ID找到用于解码的结构体
    pInCodecCtx = avcodec_alloc_context3(pInCodec) ;
    if (pInCodec == NULL)
    {
        printf("error no Codec found\n");
        return  ; // Codec not found
    }
    NSLog(@"找到音频解码器:%s",pInCodec->name) ;
    
    
    
    if(avcodec_open2(pInCodecCtx, pInCodec,NULL)<0)//将两者结合以便在下面的解码函数中调用pInCodec中的对应解码函数
    {
        printf("error avcodec_open failed.\n");
        return ; // Could not open codec
        
    }
    NSLog(@"avcodec_open success.") ;
    
    
    static AVPacket packet;
    
    printf(" bit_rate = %lld \r\n", codeParams->bit_rate);
    printf(" sample_rate = %d \r\n", codeParams->sample_rate);
    printf(" channels = %d \r\n", codeParams->channels);
    printf(" code_name = %s \r\n", pInCodec->name);
    printf(" block_align = %d\n",codeParams->block_align);
    
    uint8_t *pktdata;
    int pktsize;
    
    int out_size = AVCODEC_MAX_AUDIO_FRAME_SIZE * 100;
    uint8_t * inbuf = (uint8_t *)malloc(out_size);
    FILE* pcm;
    pcm = fopen("result.pcm","wb");
    long start = clock();
    
    AVFrame *frame = avcodec_alloc_frame
    
    while (av_read_frame(pInFmtCtx, &packet) >= 0)//pInFmtCtx中调用对应格式的packet获取函数
    {
        if(packet.stream_index==audioStream)//如果是音频
        {
            pktdata = packet.data;
            pktsize = packet.size;
            while(pktsize>0)
            {
                out_size = AVCODEC_MAX_AUDIO_FRAME_SIZE*100;
                //解码
                
                int len = avcodec_decode_audio2(pInCodecCtx, (short*)inbuf, &out_size, pktdata, pktsize);
                if (len < 0)
                {
                    printf("Error while decoding.\n");
                    break;
                }
                if(out_size > 0)
                {
                    fwrite(inbuf,1,out_size,pcm);//pcm记录
                    fflush(pcm);
                }
                pktsize -= len;
                pktdata += len;
            }
        }
        av_free_packet(&packet);
    }
    long end = clock();
    printf("cost time :%f\n",(end-start) * 1.0f / CLOCKS_PER_SEC);
    free(inbuf);
    fclose(pcm);
    if (pInCodecCtx!=NULL)
    {
        avcodec_close(pInCodecCtx);
    }
    av_close_input_file(pInFmtCtx);
     
     */
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"t2" ofType:@"mp3"] ;
    NSString *outPutFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"pcm.mp3"] ;
    NSLog(@"%@",outPutFile) ;
    const char* input_filename=filePath.UTF8String;
    av_register_all();
    AVFormatContext* container=avformat_alloc_context();
    if(avformat_open_input(&container,input_filename,NULL,NULL)<0){
        printf("Could not open file");
    }
    if(avformat_find_stream_info(container, NULL)<0){
        printf("Could not find file info");
    }
    av_dump_format(container,0,input_filename,false);
    int stream_id=-1;
    int i;
    for(i=0;i<container->nb_streams;i++){
        if(container->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
            stream_id=i;
            break;
        }
    }
    if(stream_id==-1){
        printf("Could not find Audio Stream");
    }
    AVDictionary *metadata=container->metadata;
    AVCodecContext *ctx=container->streams[stream_id]->codec;
    AVCodec *codec=avcodec_find_decoder(ctx->codec_id);
    if(codec==NULL){
        printf("cannot find codec!");
    }
    if(avcodec_open2(ctx,codec,NULL)<0){
        printf("Codec cannot be found");
    }
    enum AVSampleFormat sfmt = ctx->sample_fmt;
    AVPacket packet;
    av_init_packet(&packet);
    
    
    AVFrame *frame = av_frame_alloc() ;
    int buffer_size = AVCODEC_MAX_AUDIO_FRAME_SIZE+ FF_INPUT_BUFFER_PADDING_SIZE;;
    uint8_t buffer[buffer_size];
    packet.data=buffer;
    packet.size =buffer_size;
    FILE *outfile = fopen(outPutFile.UTF8String, "wb");
    int len;
    int frameFinished=0;
    while(av_read_frame(container,&packet) >= 0)
    {
        if(packet.stream_index==stream_id)
        {
            //printf("Audio Frame read \n");
            int len=avcodec_decode_audio4(ctx, frame, &frameFinished, &packet);
            
            if(frameFinished)
            {
                if (sfmt==AV_SAMPLE_FMT_S16P)
                { // Audacity: 16bit PCM little endian stereo
                    int16_t* ptr_l = (int16_t*)frame->extended_data[0];
                    int16_t* ptr_r = (int16_t*)frame->extended_data[1];
                    for (int i=0; i<frame->nb_samples; i++)
                    {
                        fwrite(ptr_l++, sizeof(int16_t), 1, outfile);
                        fwrite(ptr_r++, sizeof(int16_t), 1, outfile);
                    }
                    NSLog(@"解析到音频数据:%ld",frame->nb_samples * sizeof(int16_t) * 2) ;
                }
                else if (sfmt==AV_SAMPLE_FMT_FLTP)
                { //Audacity: big endian 32bit stereo start offset 7 (but has noise)
                    float* ptr_l = (float*)frame->extended_data[0];
                    float* ptr_r = (float*)frame->extended_data[1];
                    for (int i=0; i<frame->nb_samples; i++)
                    {
                        fwrite(ptr_l++, sizeof(float), 1, outfile);
                        fwrite(ptr_r++, sizeof(float), 1, outfile);
                    }
                    NSLog(@"解析到音频数据:%ld",frame->nb_samples * sizeof(float) * 2) ;
                }   
            }
        }
    }
    fclose(outfile);
    avformat_close_input(&container) ;
    
}

- (IBAction)playMp3:(id)sender {
    [self playAudio] ;
}
@end
