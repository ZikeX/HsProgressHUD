//
//  HsProgressHUD.h
//  HsProgressHUD
//
//  Created by 王金东 on 16/1/15.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HsProgressHUDCancelBlock)(void) ;

typedef NS_ENUM(NSInteger, HsProgressShowStatus) {
    HsProgressStatusNoneShow,
    HsProgressStatusDidShow,
    HsProgressStatusWillDismiss,
    HsProgressStatusDidDismiss,
};

@interface HsProgressHUD : UIView

@property (nonatomic, strong) UIImage *deleteImage;
@property (nonatomic, strong) UIImage *successImage;
@property (nonatomic, strong) UIImage *errorImage;
@property (nonatomic, strong) UIImage *warnImage;
@property (nonatomic, strong) UIImage *messageImage;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) BOOL shakeAnimation;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) HsProgressShowStatus showStatus;

@property (nonatomic, assign) BOOL cancelEnable;

+ (instancetype)shareInstance;

+ (void)setCancelEnable:(BOOL)cancelEnable;
+ (void)setDefaultContentContainerViewHeight:(CGFloat)defaultContentContainerViewHeight ;
+ (void)setDefaultContentContainerViewWidth:(CGFloat)defaultContentContainerViewWidth ;
+ (void)setMinContentContainerViewHeight:(CGFloat)minContentContainerViewHeight ;


#pragma mark ---------------------------------
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
/**
 *  @author wangjindong, 16-01-15 18:01:52
 *
 *  @brief 显示正常的提示消息
 *
 *  @param title
 *
 *  @since
 */
+ (void)showWithMessageTitle:(NSString *)title;
+ (void)showWithMessageTitle:(NSString *)title delay:(CGFloat)delay;
/**
 *  @author wangjindong, 16-01-15 18:01:06
 *
 *  @brief 显示成功的消息
 *
 *  @param title
 *
 *  @since
 */
+ (void)showWithSucessTitle:(NSString *)title;
+ (void)showWithSucessTitle:(NSString *)title delay:(CGFloat)delay;
/**
 *  @author wangjindong, 16-01-15 18:01:15
 *
 *  @brief 显示错误的消息
 *
 *  @param title
 *
 *  @since
 */
+ (void)showWithErrorTitle:(NSString *)title;
+ (void)showWithErrorTitle:(NSString *)title delay:(CGFloat)delay;
/**
 *  @author wangjindong, 16-01-15 18:01:26
 *
 *  @brief 现实警告消息
 *
 *  @param title
 *
 *  @since
 */
+ (void)showWithWarnTitle:(NSString *)title;
+ (void)showWithWarnTitle:(NSString *)title delay:(CGFloat)delay;
/**
 *  @author wangjindong, 16-01-15 18:01:36
 *
 *  @brief 消失
 *
 *  @since
 */
+ (void)dismiss;
/**
 *  @author wangjindong, 16-01-15 18:01:46
 *
 *  @brief 延迟消失
 *
 *  @param delay 消失时间
 *
 *  @since
 */
+ (void)dismissAfterDelay:(NSTimeInterval)delay;

/**
 *  @author wangjindong, 16-01-15 18:01:58
 *
 *  @brief 点击取消时的行为block
 *
 *  @param cancelBlock
 *
 *  @since 
 */
+ (void)cancelAction:(HsProgressHUDCancelBlock)cancelBlock ;

@end
