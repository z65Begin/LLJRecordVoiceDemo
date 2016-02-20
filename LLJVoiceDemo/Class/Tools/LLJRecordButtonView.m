//
//  LLJRecordButtonView.m
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import "LLJRecordButtonView.h"
#import "LLJRecordToolButton.h"

static const CGFloat buttonViewButtonH = 35;                                    // 按钮高
static const CGFloat buttonViewMargin = 5;                                      // 按钮间距
static const CGFloat buttonViewTopBorderWidth = 0.5;                            // 输入条上边框宽度
static const CGFloat buttonViewDefaultHeight = 44 + buttonViewTopBorderWidth;   // 工具条高度，和搜索条高度一致

@interface LLJRecordButtonView ()
@property (nonatomic, strong) NSMutableArray *dataSource;                      // 按钮数据源
@property (nonatomic, assign) LLJRecordButtonToolViewType toolViewType;        // 按钮类型
@end
@implementation LLJRecordButtonView

-(instancetype)initWithDataSource:(NSMutableArray *)dataSource WithType:(LLJRecordButtonToolViewType)viewType{
    
    CGRect frame = CGRectMake(0, screenHeight, screenWidth, buttonViewDefaultHeight);
    
    return [self initWithDataSource:dataSource WithType:viewType frame:frame];
    
}

- (instancetype)initWithDataSource:(NSMutableArray *)dataSource WithType:(LLJRecordButtonToolViewType)viewType frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = dataSource;
        _toolViewType = viewType;
        [self setup];
        
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    // 上边框
    //    [self setBorder:RHBorderPositionTop];
    CALayer *borderLaer = [CALayer layer];
    borderLaer.backgroundColor = RGBACOLOR(210, 210, 210, 1).CGColor;
    borderLaer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5);
    [self.layer addSublayer:borderLaer];
    
    NSInteger count = self.dataSource.count;
    // 算出每个按钮宽度
    CGFloat btnWidth = (screenWidth - (count + 1) * buttonViewMargin) / (count * 1.0);
    // 构造按钮
    for (NSInteger i = 0; i < count; i++) {
        LLJRecordButtonOption *toolOption = self.dataSource[i];
        LLJRecordToolButton *button = [self buttonWithTitle:toolOption];
        button.enabled = toolOption.enable;
        button.tag = i;
         button.frame = CGRectMake((i + 1) * buttonViewMargin + i * btnWidth, 5, btnWidth, buttonViewButtonH);
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        //        字体颜色
        if (self.toolViewType == LLJButtonToolViewTypeText) {
            if (toolOption.enable) {
                button.alpha = 1;
            } else {
                button.alpha = 0.3;
            }
//            if (toolOption.textColor) {
//                [button setTitleColor:toolOption.textColor forState:UIControlStateNormal];
//            }
        }
        [self.buttons addObject:button];
        [self addSubview:button];
    }
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (LLJRecordToolButton *)buttonWithTitle:(LLJRecordButtonOption *)toolOption {
    CGFloat y = (buttonViewDefaultHeight - buttonViewButtonH) / 2;
    CGRect btnFrame = CGRectMake(0, y, 35, buttonViewButtonH);
    LLJRecordToolButton *button = [[LLJRecordToolButton alloc] initWithFrame:btnFrame option:toolOption type:self.toolViewType];
    return button;
}

- (void)buttonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(buttonView:clickedWithButtonIndex:andOption:)]) {
        if (button.tag == 3) {
            button.selected = !button.selected;
            [self refreshButtons:button.selected];
        }
        [self.delegate buttonView:self clickedWithButtonIndex:button.tag andOption:self.dataSource[button.tag]];
    }
}

- (void)refreshButtons:(BOOL)selected {
    NSInteger count = self.buttons.count;
    if (selected) {
        CGFloat maxWidth = 100;
        CGFloat btnWidth = (screenWidth - maxWidth - count * buttonViewMargin) / ((count -1) * 1.0);
        [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LLJRecordToolButton *button = (LLJRecordToolButton *)obj;
            if (idx < 3) {
                
                button.frame = CGRectMake((idx + 1) * buttonViewMargin + idx * btnWidth, 5, btnWidth, buttonViewButtonH);
            } else {
                button.frame = CGRectMake(screenWidth - maxWidth - buttonViewMargin, 5, maxWidth, buttonViewButtonH);
                LLJRecordButtonOption *toolOption = self.dataSource[idx];
                toolOption.type = LLJButtonToolViewTypeImageWithText;
                toolOption.title = @"00:00";
                toolOption.imageName = nil;
                toolOption.bgImageName = @"Fav_Note_ToolBar_Voice_HL";
                [button refreshBtnWithOption:toolOption];
            }
        }];
    } else {
        [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LLJRecordToolButton *button = (LLJRecordToolButton *)obj;
            CGFloat btnWidth = (screenWidth - (count + 1) * buttonViewMargin) / (count * 1.0);

            button.frame = CGRectMake((idx + 1) * buttonViewMargin + idx * btnWidth, 5, btnWidth, buttonViewButtonH);
            if (idx == 3) {
                LLJRecordButtonOption *toolOption = self.dataSource[idx];
                toolOption.type = LLJButtonToolViewTypeImage;
                toolOption.imageName = @"Fav_Note_ToolBar_Voice";
                toolOption.title = @"";
                toolOption.bgImageName = nil;
                [button refreshBtnWithOption:toolOption];
            }
        }];
    }
}

- (void)modifyVoiceButtonTitle:(NSString *) title {
    if (self.buttons.count > 3) {
        LLJRecordToolButton * voiceButton = self.buttons[3];
        if (voiceButton.selected) {
            voiceButton.contenLabel.text = title;
        } else {
            voiceButton.contenLabel.text = @"";
        }
    }
}





- (void) reloadToolView
{
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LLJRecordToolButton *button = (LLJRecordToolButton *)obj;
        LLJRecordButtonOption *toolOption = self.dataSource[idx];
        button.enabled = toolOption.enable;
        if (self.toolViewType == LLJButtonToolViewTypeText) {
            if (idx == 0) {
                [button refreshBtnWithOption:toolOption];
            }
            if (toolOption.enable) {
                button.alpha = 1.0f;
            } else {
                button.alpha = 0.3f;
            }
        }
    }];
}



@end
