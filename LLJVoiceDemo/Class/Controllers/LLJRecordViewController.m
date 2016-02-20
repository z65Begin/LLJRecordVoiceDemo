//
//  LLJRecordViewController.m
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//
/*
 iOS的录音功能主要依靠AVFoundation.framework与CoreAudio.framework来实现,故使用时需倒入这两个框架,
 并遵循AVAudioRecorderDelegate
*/

#import "LLJRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LLJRecordButtonOption.h"
#import "LLJRecordToolButton.h"
#import "LLJRecordButtonView.h"
#import <YYText.h>
#import "LLJVoicePlayView.h"
//#import "LLJRecordInsertView.h"
#define kRecordAudioFile @"LLJRecord.caf"

static const CGFloat kbtnHeight = 49.f;                         //工具条的高度

@interface LLJRecordViewController ()<AVAudioRecorderDelegate, LLJRecordButtonViewDelegate, YYTextViewDelegate, LLJVoicePlayViewDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) LLJRecordButtonView * toolsView;     //底部工具view
@property (nonatomic, strong) NSMutableArray * btnSource;          //工具条按钮资源
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) NSTimer *timer;                      //录音时间监控
@property (nonatomic, assign) NSInteger recordTime;                //录音时间
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) LLJVoicePlayView *playView;


//@property (nonatomic, strong) LLJRecordInsertView *voiceInsertView;

@end

@implementation LLJRecordViewController

- (void)viewDidLoad{
    
    [self buildView];
    [self setAudioSession];
}

#pragma mark 构建UI
- (void)buildView{
    
    [self.textView addSubview:self.progressView];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.playView];
}

#pragma mark 初始化
- (YYTextView *)textView{
    if (!_textView) {
        _textView = [[YYTextView alloc]initWithFrame:self.view.frame];
        NSMutableAttributedString *mAtt = [[NSMutableAttributedString alloc]initWithString:@""];
        [mAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, mAtt.length)];
        mAtt.yy_lineSpacing = 8.0f;
        
        _textView.selectedRange = NSMakeRange(mAtt.length, 0);
        _textView.attributedText = mAtt;
        
        _textView.delegate = self;
        _textView.textColor = RGBACOLOR(40.0, 40.0, 40.0, 1);
        _textView.font = [UIFont systemFontOfSize:20];
        _textView.showsVerticalScrollIndicator = YES;
        _textView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
        _textView.scrollEnabled = YES;//是否可以拖动
        
        _textView.inputAccessoryView  = [self toolsView];
        _textView.scrollEnabled = YES;
        _textView.contentSize = CGSizeZero;
        _textView.showsVerticalScrollIndicator = YES;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        }
    }
        
        return _textView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(20, 100, screenWidth - 40, 20)];
        _progressView.backgroundColor = [UIColor redColor];
    }
    return _progressView;
}

- (LLJVoicePlayView *)playView{
    if (!_playView) {
        
        _playView = [[LLJVoicePlayView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
        _playView.backgroundColor = RGBACOLOR(255, 255, 255, 1);
        _playView.delegate = self;
        
        [self audioPlayer];
    }
    return _playView;
}
- (LLJRecordButtonView *)toolsView{
    if (!_toolsView) {
        _toolsView = [[LLJRecordButtonView alloc]initWithDataSource:self.btnSource WithType:LLJButtonToolViewTypeImage frame:CGRectMake(0, 0, screenWidth, kbtnHeight)];
        _toolsView.delegate = self;
        _toolsView.backgroundColor = [UIColor whiteColor];
    }
    
    return _toolsView;
}

- (NSMutableArray *)btnSource{
    if (!_btnSource) {
        _btnSource = [[NSMutableArray alloc] initWithCapacity:0];
        // 相册
        LLJRecordButtonOption * album = [[LLJRecordButtonOption alloc] init];
        album.imageName = @"Fav_Note_ToolBar_Album@2x.png";
        album.enable = YES;
        album.type = LLJButtonToolViewTypeImage;
        
        // 相机
        LLJRecordButtonOption * camera = [[LLJRecordButtonOption alloc] init];
        camera.imageName = @"Fav_Note_ToolBar_Camera@2x.png";
        camera.enable = YES;
        camera.type = LLJButtonToolViewTypeImage;
        
        // 地图
        LLJRecordButtonOption * map = [[LLJRecordButtonOption alloc] init];
        map.imageName = @"Fav_Note_ToolBar_Location@2x.png";
        map.enable = YES;
        map.type = LLJButtonToolViewTypeImage;
        
        // 语音
        LLJRecordButtonOption *voice = [[LLJRecordButtonOption alloc] init];
        voice.imageName = @"Fav_Note_ToolBar_Voice@2x.png";
        voice.enable = YES;
        voice.type = LLJButtonToolViewTypeImage;
        
        [_btnSource addObject:album];
        [_btnSource addObject:camera];
        [_btnSource addObject:map];
        [_btnSource addObject:voice];
        
    }
    return _btnSource;
}

#pragma mark - RHBottomToolViewDelegate
-(void)buttonView:(LLJRecordButtonView *)buttonView clickedWithButtonIndex:(NSInteger)currentIndex andOption:(LLJRecordButtonView *)option {
    if (currentIndex == 0) {
        //选择照片
        NSLog(@"选择照片");
    } else if (currentIndex == 1) {
        //打开相机
    NSLog(@"打开相机");

    } else if (currentIndex == 2) {
        //地图
        NSLog(@"打开地图");
        [self playVoice];

    } else {
        //语音
        LLJRecordToolButton *voiceButton = buttonView.buttons[3];
        if (voiceButton.selected) {
            [self startRecord];
        }else{
            [self stopRecord];
        }
    }
}

#pragma mark 录音相关
- (void)startRecord{
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder record];
        self.recordTime = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [self.textView becomeFirstResponder];
}

- (void)stopRecord{
    if (self.timer) {
        [self.timer invalidate];
        [self.audioRecorder stop];
    }
    NSLog(@"停止");

}

#pragma mark 录音私有方法
- (void)setAudioSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

//创建录音
- (AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        NSURL *strUrl = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        
        NSError *error = nil;
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
     
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:strUrl settings:setting error:&error
                          ];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
    }
    return _audioRecorder;
}

//创建播放器
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url = [self getSavePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

//录音路径
- (NSURL *)getSavePath{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    urlStr = [urlStr stringByAppendingString:kRecordAudioFile];
    DLog(@"urlStr = %@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

//录音设置
- (NSDictionary *)getAudioSetting{
    //录音设置
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [dicM setObject:@(11025) forKey:AVSampleRateKey];
    //录音通道数 1 或 2
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //录音的质量
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    //....其他设置等
    return dicM;
}

#pragma mark - 录音机代理方法 AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    NSURL *url = recorder.url;
//    NSString *timeStr = [self recordTimeStr:self.recordTime];
//    [self.voiceInsertView showRecording:timeStr voiceUrl:[url absoluteString]];
    
    //指控录音时间
    self.recordTime = 0;
    NSLog(@"录音完成");

    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

//更新记录时间
- (void)updateRecordTime{
    self.recordTime ++;
    [self.toolsView modifyVoiceButtonTitle:[self recordTimeStr:self.recordTime]];
    
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    
    [self.progressView setProgress:progress];
}

//获取录音字符串
- (NSString *)recordTimeStr:(NSInteger)recordTime {
    NSInteger second = recordTime % 60;
    NSInteger minute = recordTime / 60;
    NSString *title = [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
    return title;
}

//播放语音
- (void)playVoice{
    
    [self.playView playVoiceWithUrl:[self getSavePath]];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO; // 禁止滑动返回


}

- (void)playFinishClicked{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //移除播放view
    [self.playView removeFromSuperview];
}

@end
