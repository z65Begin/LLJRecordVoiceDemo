//
//  LLJRecordButtonOption.h
//  LLJVoiceDemo
//
//  Created by 刘良局 on 16/2/19.
//  Copyright © 2016年 ruaho. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LLJRecordButtonToolViewType){
    LLJButtonToolViewTypeImage = 1,                     //图片
    LLJButtonToolViewTypeText,                          //文字
    LLJButtonToolViewTypeImageWithText,                 //图片配标题
};

@interface LLJRecordButtonOption : NSObject
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  图片名称
 */
@property (nonatomic, copy) NSString *imageName;
/**
 *  高亮图片名称
 */
@property (nonatomic, copy) NSString *imageNameH;
/**
 *  背景图片名称
 */
@property (nonatomic, copy) NSString *bgImageName;
/**
 *  是否可用
 */
@property (nonatomic, assign) BOOL enable;
/**
 *  按钮是否含有图片
 */
@property (nonatomic, assign) LLJRecordButtonToolViewType type;
/**
 *  字体颜色
 */
//@property (nonatomic,strong) UIColor *textColor;

@end
