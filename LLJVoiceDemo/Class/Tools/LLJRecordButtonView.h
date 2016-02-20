//
//  LLJRecordButtonView.h
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLJRecordButtonOption.h"

@class LLJRecordButtonView;

@protocol LLJRecordButtonViewDelegate <NSObject>

- (void)buttonView:(LLJRecordButtonView *)buttonView clickedWithButtonIndex:(NSInteger )currentIndex andOption:(LLJRecordButtonView *)option;
@end

@interface LLJRecordButtonView : UIView

@property (nonatomic, weak)id <LLJRecordButtonViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *buttons; //所有按钮

- (instancetype)initWithDataSource:(NSMutableArray *)dataSource WithType:(LLJRecordButtonToolViewType )viewType;

//设置frame
- (instancetype)initWithDataSource:(NSMutableArray *)dataSource WithType:(LLJRecordButtonToolViewType )viewType frame:(CGRect )frame;
//刷新视图
- (void)reloadToolView;
//修改toolView标题
- (void)modifyVoiceButtonTitle:(NSString *)title;

- (void)refreshButtons:(BOOL)selected;

@end
