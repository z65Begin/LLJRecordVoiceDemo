//
//  LLJRecordToolButton.m
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import "LLJRecordToolButton.h"

@interface LLJRecordToolButton ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) LLJRecordButtonOption *option;
@property (nonatomic, assign) LLJRecordButtonToolViewType toolViewType;

@end
@implementation LLJRecordToolButton

- (instancetype)initWithFrame:(CGRect)frame option:(LLJRecordButtonOption *)option type:(LLJRecordButtonToolViewType)type{
    
    self = [super initWithFrame:frame];
    if (self) {
        _option = option;
        _toolViewType = type;
        
        [self setup];
        [self setContent];
    }
    
    return self;
}

-(void)refreshBtnWithOption:(LLJRecordButtonOption *)option{
    _option = option ?: _option;
    [self setContent];
}

- (void)setup{
    [self addSubview:self.icon];
    [self addSubview:self.contenLabel];
}

- (UIImageView *)icon{
    
    if (!_icon) {
        _icon = [[UIImageView alloc]initWithFrame:CGRectZero];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _icon;
}

- (UILabel *)contenLabel{
    
    if (!_contenLabel) {
        _contenLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _contenLabel.textAlignment = NSTextAlignmentCenter;
        _contenLabel.font = [UIFont systemFontOfSize:13];
    }
    return _contenLabel;
}

- (void)setContent{
    self.icon.image = self.option.imageName ? [UIImage imageNamed:self.option.imageName] : nil;
    if (self.option.bgImageName) {
        [self setBackgroundImage:[UIImage imageNamed:self.option.bgImageName] forState:UIControlStateNormal];
    }else{
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    }
    self.contenLabel.text = self.option.title;
    self.contenLabel.textColor = [UIColor blackColor];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setButtonFrames];
}

- (void)setButtonFrames{
    
    CGFloat height = 35;
    CGFloat width = 73.75;
    CGFloat iconW = height * 0.928;
    CGFloat iconH = height * 0.8;
    CGFloat iconX = (width - iconW) * 0.5;
    CGFloat iconY = (height - iconH) * 0.5;
    if (self.option.type == LLJButtonToolViewTypeImage) {
        self.icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    } else if (self.option.type == LLJButtonToolViewTypeImageWithText) {
        iconW = width * 0.6;
        iconH = height * 0.8;
        iconX = 0;
        iconY = (height - iconH) * 0.5;
        
        CGFloat contentLabelW = width * 0.5;
        CGFloat contentLabelH = height;
        CGFloat contentLabelX = contentLabelW;
        CGFloat contentLabelY = 0;
        self.icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
        self.contenLabel.frame = CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH);
    }
}

@end
