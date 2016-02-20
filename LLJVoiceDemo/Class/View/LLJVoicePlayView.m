//
//  LLJVoicePlayView.m
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/20.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import "LLJVoicePlayView.h"
#import "Masonry.h"

@interface LLJVoicePlayView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) UISlider *timeSlider;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong)  AVAudioPlayer *voicePlayer;      //语音播放器
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LLJVoicePlayView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    WS(ws);
    
    CGFloat lineSpace = 8.0f;//lineSpace  大小为8
    UIEdgeInsets padding = UIEdgeInsetsMake(lineSpace, lineSpace, lineSpace, lineSpace);
    
    [self addSubview:self.playButton];
    [self addSubview:self.leftLabel];
    [self addSubview:self.timeSlider];
    [self addSubview:self.rightLabel];
    [self addSubview:self.doneButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.mas_centerY).offset(10);
        make.left.mas_equalTo(ws.mas_left).offset(padding.left);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.mas_centerY).offset(10);
        make.left.mas_equalTo(ws.playButton.mas_right).offset(padding.left);
        make.size.mas_equalTo(CGSizeMake(30, 25));
    }];
    
    [self.timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.mas_centerY).offset(10);
        make.left.mas_equalTo(ws.leftLabel.mas_right).offset(padding.left);
        make.right.mas_equalTo(ws.rightLabel.mas_left).offset(- padding.left);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.mas_centerY).offset(10);
        make.right.mas_equalTo(ws.doneButton.mas_left).offset(- padding.left);
        make.size.mas_equalTo(CGSizeMake(30, 25));
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.mas_centerY).offset(10);
        make.right.mas_equalTo(ws.mas_right).offset(- padding.left);
        make.size.mas_equalTo(CGSizeMake(35, 25));
        
    }];
    
//                    [_playButton setBackgroundImage:[UIImage imageNamed:@"Fav_VoicePlayer_Pause"] forState:UIControlStateNormal];

}

#pragma mark 初始化
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [[UIButton alloc]init];
//                [_playButton setBackgroundImage:[UIImage imageNamed:@"Fav_VoicePlayer_Play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _playButton;
}

- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.text = @"00:00";
        _leftLabel.font = [UIFont systemFontOfSize:12];
        
    }
    return _leftLabel;
}

- (UISlider *)timeSlider{
    if (!_timeSlider) {
        _timeSlider = [[UISlider alloc]init];
        
        UIImage *image = [UIImage imageNamed:@"playerplan_button"];
        image = [image stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        
        [_timeSlider setThumbImage:image forState:UIControlStateNormal];
        [_timeSlider setMinimumTrackImage:image forState:UIControlStateNormal];
        [_timeSlider setMaximumTrackImage:image forState:UIControlStateNormal];
        _timeSlider.minimumTrackTintColor = [UIColor blueColor];
        _timeSlider.maximumTrackTintColor = [UIColor grayColor];
        
        _timeSlider.minimumValue = 0.0f;
        _timeSlider.value = 0.0;
        
        [_timeSlider addTarget:self action:@selector(dragSliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _timeSlider;
}

- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc]init];
        _rightLabel.text = [self covertTimeToString:self.voicePlayer.duration];;
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = [UIFont systemFontOfSize:12];
    }
    return _rightLabel;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [[UIButton alloc]init];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _doneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_doneButton setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
    }
    
    return _doneButton;
}

#pragma mark - 转换时间格式
- (NSString *)covertTimeToString:(NSTimeInterval)seconds {
    
    NSInteger min = seconds / 60;             //分钟
    NSInteger sec = (NSInteger)seconds % 60;  //秒
    //%02d 表示显示两位数的整数且十位用0占位
    NSString *string = [NSString stringWithFormat:@"%02ld:%02ld",min, sec];
    return string;
}

//播放、暂停
- (void)playAction:(UIButton *)sender {
    if (!self.voicePlayer.isPlaying) {//如过没有播放
        //播放
        [self.voicePlayer play];
        //如果定时器不存在
        if (!self.timer) {
            //开启定时器
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                          target:self
                                                        selector:@selector(changeSliderValue)
                                                        userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [_playButton setImage:[UIImage imageNamed:@"Fav_VoicePlayer_Pause"] forState:UIControlStateNormal];

        }
        
        //如果正在播放，图片换成暂停
        [sender setImage:[UIImage imageNamed:@"Fav_VoicePlayer_Play"] forState:UIControlStateNormal];
    } else {
        //如果定时器存在
        if (self.timer) {
            //停止定时器
            [self.timer invalidate];
            self.timer = nil;
        }
        //暂停
        [self.voicePlayer pause];
        //如果暂停图片换成播放
        [sender setImage:[UIImage imageNamed:@"Fav_VoicePlayer_Pause"] forState:UIControlStateNormal];
    }
}
#pragma mark
//拖拽改变进度条的值
- (void)dragSliderChangeValue:(UISlider *)slider {
    //根据进度求出需要播放的时间点
    NSTimeInterval currentTime = slider.value;
    //根据进度条的值改变播放的进度
    self.voicePlayer.currentTime = currentTime;
}

//根据播放进度改变进度条的值和显示的播放时间,每隔1秒变化一次
- (void)changeSliderValue {
    //获取歌曲当前的时间
    NSTimeInterval time = self.voicePlayer.currentTime;
    
    //改变播放时间的显示
    self.leftLabel.text = [self covertTimeToString:time];
    
    //修改 slider 的值
    self.timeSlider.value = time;
    
}

- (void)playVoiceWithUrl:(NSURL *)url {
    
    if (!_voicePlayer) {
        
        /*************** 测试换成控制器传过来的url即可  *******************/
        NSString *songPath = [[NSBundle mainBundle] pathForResource:@"徐佳莹我好想你.mp3" ofType:nil];
        //把字符串路径转换成url路径 加载本地音乐路径：fileURLWithPath:
        NSURL *songUrl = [NSURL fileURLWithPath:songPath];
        /****************测试******************/

        //初始化播放器
        self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songUrl error:nil];
        //设置代理
        self.voicePlayer.delegate = self;
        //准备播放
        [self.voicePlayer prepareToPlay];
        self.rightLabel.text = [self covertTimeToString:self.voicePlayer.duration];
        self.timeSlider.maximumValue = self.voicePlayer.duration;
    }
    [self playAction:nil];
}


@end
