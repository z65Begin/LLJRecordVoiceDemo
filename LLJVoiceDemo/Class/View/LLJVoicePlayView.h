//
//  LLJVoicePlayView.h
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/20.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class LLJVoicePlayView;

@protocol LLJVoicePlayViewDelegate <NSObject>

- (void)playFinishClicked;

@optional

@end

@interface LLJVoicePlayView : UIView

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, weak)id <LLJVoicePlayViewDelegate> delegate;

- (void)playVoiceWithUrl:(NSURL *)url;

@end
