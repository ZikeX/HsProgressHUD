//
//  HsProgressHUD.m
//  HsProgressHUD
//
//  Created by 王金东 on 16/1/15.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsProgressHUD.h"
#import "HsProgressLoadingView.h"

#define contentViewWidth 220
#define contentViewHeight 50
#define deleteViewWidth 50
#define defaultTitleHeight 20
#define titlePadding 10

typedef NS_ENUM(NSInteger, HsProgressStatus) {
    HsProgressStatusLoading,
    HsProgressStatusSucess,
    HsProgressStatusError,
    HsProgressStatusWarn,
    HsProgressStatusMessage,
};


@interface HsProgressHUD ()

//superView 要显示在的父视图
@property (nonatomic,weak) UIView *showInView;
//中间视图
@property (nonatomic,strong) UIView *centerView;
//内容视图
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIView *loadingView;
@property (nonatomic,strong) UILabel *titleView;
//操作按钮
@property (nonatomic,strong) UIButton *opearButton;
//分割线
@property (nonatomic,strong) UIView *lineView;
//是否在显示
@property (nonatomic,assign) BOOL isShowing;

@property (nonatomic,strong) UIImage *deleteImage;
@property (nonatomic,strong) UIImage *successImage;
@property (nonatomic,strong) UIImage *errorImage;
@property (nonatomic,strong) UIImage *warnImage;
@property (nonatomic,strong) UIImage *messageImage;

@property (nonatomic,assign) HsProgressStatus status;
@property (nonatomic,copy) HsProgressHUDCancelBlock cancelBlock;

@end

@implementation HsProgressHUD{
    HsProgressStatus _lastStatus;
}

+ (instancetype)shareInstance {
    static dispatch_once_t once;
    static HsProgressHUD *shareView;
    dispatch_once(&once, ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        shareView = [[self alloc] initWithFrame:window.bounds];
        shareView.showInView = window;
        shareView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [shareView setupLayout];
        [shareView setupStyle];
    });
    return shareView;
}

//初始化视图布局
- (void)setupLayout {
    self.centerView = [[UIView alloc] init];
    [self addSubview:self.centerView];
    
    self.contentView = [[UIView alloc] init];
    [self.centerView addSubview:self.contentView];
    
    self.loadingView = [[UIView alloc] init];
    [self.contentView addSubview:self.loadingView];
    
    self.titleView = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleView];
    
    
    self.opearButton = [[UIButton alloc] init];
    [self.centerView addSubview:self.opearButton];
    
    self.lineView = [[UIView alloc] init];
    [self.opearButton addSubview:self.lineView];
    
    [self resetFrame];
}
//初始化样式
- (void)setupStyle {
    self.centerView.backgroundColor = [UIColor blackColor];
    self.centerView.layer.cornerRadius = 4;
    self.centerView.layer.masksToBounds = YES;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.titleView.font = [UIFont systemFontOfSize:14.0f];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.numberOfLines = 0;
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.textColor = [UIColor whiteColor];
    
    self.opearButton.backgroundColor = [UIColor clearColor];
    
    self.lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.4];
    
    [self.opearButton addTarget:self action:@selector(buttonTap) forControlEvents:UIControlEventTouchUpInside];
    
    NSBundle *bundle =  [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"HsProgressBundle" withExtension:@"bundle"]];
    self.deleteImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"delete@2x" ofType:@"png"]];
    self.successImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"success@2x" ofType:@"png"]];
    self.errorImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"error@2x" ofType:@"png"]];
    self.warnImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"warn@2x" ofType:@"png"]];
    self.messageImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"message@2x" ofType:@"png"]];
}

#pragma mark ---------------- reset layout and style ----------------------
- (void)resetFrame {
    if (_status == HsProgressStatusLoading) {
        CGFloat height = contentViewHeight;
        CGFloat titleHeight = 20;
        if (self.titleView.text.length > 0) {
            CGRect rect= [self.titleView.text boundingRectWithSize:CGSizeMake(contentViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleView.font} context:nil];
            titleHeight = rect.size.height + 10;
        }
        height += titleHeight;
        
        self.centerView.frame = CGRectMake((self.showInView.frame.size.width-contentViewWidth)/2, (self.showInView.frame.size.height-height)/2, contentViewWidth, height);
        self.contentView.frame = CGRectMake(0, 0, self.centerView.frame.size.width-deleteViewWidth, self.centerView.frame.size.height);
        self.loadingView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-titleHeight);
        self.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(self.loadingView.frame), self.contentView.frame.size.width-titlePadding*2, titleHeight);
        self.opearButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, deleteViewWidth, self.centerView.frame.size.height);
        self.lineView.frame = CGRectMake(0, 0, 1, self.opearButton.frame.size.height);
        [self.opearButton setImage:self.deleteImage forState:UIControlStateNormal];
        self.opearButton.enabled = YES;
    }else if (_status == HsProgressStatusSucess || _status == HsProgressStatusMessage) {
        CGFloat height = 10;
        CGFloat titleHeight = 20;
        if (self.titleView.text.length > 0) {
            CGRect rect= [self.titleView.text boundingRectWithSize:CGSizeMake(contentViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleView.font} context:nil];
            titleHeight = rect.size.height + 10;
        }
        height += titleHeight;
        height = height < contentViewHeight ?contentViewHeight:height;
        
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:9 options:0 animations:^{
            self.centerView.frame = CGRectMake((self.showInView.frame.size.width-contentViewWidth)/2, (self.showInView.frame.size.height-height)/2, contentViewWidth, height);
            self.contentView.frame = CGRectMake(0, 0, self.centerView.frame.size.width-deleteViewWidth, self.centerView.frame.size.height);
            self.loadingView.frame = CGRectZero;
            self.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(self.loadingView.frame), self.contentView.frame.size.width-titlePadding*2, height);
            self.opearButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, deleteViewWidth, self.centerView.frame.size.height);
            self.lineView.frame = CGRectMake(0, 0, 1, self.opearButton.frame.size.height);
            if (_status == HsProgressStatusSucess) {
                [self.opearButton setImage:self.successImage forState:UIControlStateNormal];
            }else if (_status == HsProgressStatusMessage){
                [self.opearButton setImage:self.messageImage forState:UIControlStateNormal];
            }
            
        } completion:^(BOOL finished) {
        }];        
    }else if (_status == HsProgressStatusError || _status == HsProgressStatusWarn) {
        __weak HsProgressHUD *_weaskSelf = self;
        void(^changeFrame)(void) = ^{
            CGFloat height = 10;
            CGFloat titleHeight = 20;
            if (_weaskSelf.titleView.text.length > 0) {
                CGRect rect= [_weaskSelf.titleView.text boundingRectWithSize:CGSizeMake(contentViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_weaskSelf.titleView.font} context:nil];
                titleHeight = rect.size.height + 10;
            }
            height += titleHeight;
            height = height < contentViewHeight ?contentViewHeight:height;
            _weaskSelf.centerView.frame = CGRectMake((_weaskSelf.showInView.frame.size.width-contentViewWidth)/2, (_weaskSelf.showInView.frame.size.height-height)/2, contentViewWidth, height);
            _weaskSelf.contentView.frame = CGRectMake(0, 0, _weaskSelf.centerView.frame.size.width-deleteViewWidth, _weaskSelf.centerView.frame.size.height);
            _weaskSelf.loadingView.frame = CGRectZero;
            _weaskSelf.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(_weaskSelf.loadingView.frame), _weaskSelf.contentView.frame.size.width-titlePadding*2, height);
            _weaskSelf.opearButton.frame = CGRectMake(CGRectGetMaxX(_weaskSelf.contentView.frame), 0, deleteViewWidth, _weaskSelf.centerView.frame.size.height);
            _weaskSelf.lineView.frame = CGRectMake(0, 0, 1, _weaskSelf.opearButton.frame.size.height);
            if (_status == HsProgressStatusError) {
                [_weaskSelf.opearButton setImage:_weaskSelf.errorImage forState:UIControlStateNormal];
            }else if (_status == HsProgressStatusWarn){
                [_weaskSelf.opearButton setImage:_weaskSelf.warnImage forState:UIControlStateNormal];
            }
        };
        if (_lastStatus == HsProgressStatusLoading) {
            changeFrame();
            [self shakeAnimationForView:self.centerView];
        }else{
             [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:9 options:0 animations:^{
                 changeFrame();
             } completion:^(BOOL finished) {
                [self shakeAnimationForView:self.centerView];
             }];
        }
        
    }
}

#pragma mark 抖动动画
- (void)shakeAnimationForView:(UIView *)view {
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:.06];
    // 设置次数
    [animation setRepeatCount:3];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)setStatus:(HsProgressStatus)status {
    _lastStatus = _status;
    _status = status;
}


- (void)show {
    [self showWithTitle:nil];
}

- (void)showWithTitle:(NSString *)title {
    if (self.isShowing) {
        return;
    }
    self.isShowing = YES;
    self.status = HsProgressStatusLoading;
    self.titleView.text = title;
    [self.showInView addSubview:self];
    [self resetFrame];
    
    HsProgressLoadingView *loadingView = [[HsProgressLoadingView alloc] initWithFrame:self.loadingView.bounds];
    [self.loadingView addSubview:loadingView];
}
- (void)showWithTitle:(NSString *)title status:(HsProgressStatus)status delay:(CGFloat)delay{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self immediatelyDismiss];
    [self clearLoadingView];
    self.isShowing = YES;
    self.status = status;
    self.titleView.text = title;
    [self.showInView addSubview:self];
    [self resetFrame];
    if (delay > 0) {
        [self dismissAfterDelay:delay];
    }
}
- (void)showWithSucessTitle:(NSString *)title {
    [self showWithTitle:title status:HsProgressStatusSucess delay:3.0f];
}
- (void)showWithMessageTitle:(NSString *)title {
    [self showWithTitle:title status:HsProgressStatusMessage delay:3.0f];
}

- (void)showWithErrorTitle:(NSString *)title {
    [self showWithTitle:title status:HsProgressStatusError delay:0.0f];
}

- (void)showWithWarnTitle:(NSString *)title {
    [self showWithTitle:title status:HsProgressStatusWarn delay:0.0f];
}

- (void)immediatelyDismiss {
    [self clearLoadingView];
    self.isShowing = NO;
    [self removeFromSuperview];
}
- (void)dismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [self immediatelyDismiss];
        self.alpha = 1.0f;
    }];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}

- (void)clearLoadingView {
    for (UIView *view in self.loadingView.subviews) {
        [view removeFromSuperview];
    }
}
- (void)buttonTap {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}
#pragma mark ------------------------------------------------
+ (void)show{
    [[HsProgressHUD shareInstance] show];
}

+ (void)showWithTitle:(NSString *)title {
    [[HsProgressHUD shareInstance] showWithTitle:title];
}

+ (void)showWithSucessTitle:(NSString *)title {
    [[HsProgressHUD shareInstance] showWithSucessTitle:title];
}
+ (void)showWithMessageTitle:(NSString *)title {
    [[HsProgressHUD shareInstance] showWithMessageTitle:title];
}

+ (void)showWithErrorTitle:(NSString *)title {
    [[HsProgressHUD shareInstance] showWithErrorTitle:title];
}

+ (void)showWithWarnTitle:(NSString *)title {
    [[HsProgressHUD shareInstance] showWithWarnTitle:title];
}
+ (void)dismiss {
    [[HsProgressHUD shareInstance] dismiss];
}

+ (void)dismissAfterDelay:(NSTimeInterval)delay {
    [[HsProgressHUD shareInstance] dismissAfterDelay:delay];
}
+ (void)cancelAction:(HsProgressHUDCancelBlock)cancelBlock {
    [HsProgressHUD shareInstance].cancelBlock = cancelBlock;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
