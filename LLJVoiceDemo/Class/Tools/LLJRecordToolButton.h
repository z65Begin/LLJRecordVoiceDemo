//
//  LLJRecordToolButton.h
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLJRecordButtonView.h"
#import "LLJRecordButtonOption.h"
#import "Masonry.h"

@interface LLJRecordToolButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame option:(LLJRecordButtonOption *)option type:(LLJRecordButtonToolViewType )type;

- (void)refreshBtnWithOption:(LLJRecordButtonOption *)option;

//按钮下方文字
@property (nonatomic, strong) UILabel *contenLabel;


@end
