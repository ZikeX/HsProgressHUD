//
//  HsProgressHUD.h
//  HsProgressHUD
//
//  Created by 王金东 on 16/1/15.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HsProgressHUD : UIView

/**
 *  @author wangjindong, 16-01-15 13:01:03
 *
 *  @brief 显示等待框
 *
 *  @since
 */
+ (void)show;

/**
 *  @author wangjindong, 16-01-15 13:01:16
 *
 *  @brief 显示title
 *
 *  @param title
 *
 *  @since
 */
+ (void)showWithTitle:(NSString *)title;

+ (void)showWithMessageTitle:(NSString *)title;

+ (void)showWithSucessTitle:(NSString *)title;

+ (void)showWithErrorTitle:(NSString *)title;

+ (void)showWithWarnTitle:(NSString *)title;

+ (void)dismiss;

+ (void)dismissAfterDelay:(NSTimeInterval)delay;

@end
