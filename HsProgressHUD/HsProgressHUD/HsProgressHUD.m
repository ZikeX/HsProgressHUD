//
//  HsProgressHUD.m
//  HsProgressHUD
//
//  Created by 王金东 on 16/1/15.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsProgressHUD.h"

#define deleteViewWidth 50
#define titlePadding 10

typedef NS_ENUM(NSInteger, HsProgressStatus) {
    HsProgressStatusLoading,
    HsProgressStatusSucess,
    HsProgressStatusError,
    HsProgressStatusWarn,
    HsProgressStatusMessage,
};

static float _defaultContentContainerViewWidth = 220;
static float _defaultContentContainerViewHeight = 50;
static float _minContentContainerViewHeight = 50;

@interface HsProgressHUD ()

//superView 要显示在的父视图
@property (nonatomic,weak) UIView *showInView;
//中间视图
@property (nonatomic,strong) UIView *centerContainerView;
//内容视图
@property (nonatomic,strong) UIView *contentContainerView;
@property (nonatomic,strong) UIView *loadingContainerView;
@property (nonatomic,strong) UILabel *titleView;
//操作按钮
@property (nonatomic,strong) UIButton *opearButton;
//分割线
@property (nonatomic,strong) UIView *lineView;


@property (nonatomic,assign) HsProgressStatus status;
@property (nonatomic,copy) HsProgressHUDCancelBlock cancelBlock;

@end

@implementation HsProgressHUD{
    HsProgressStatus _lastStatus;
}

+ (void)setDefaultContentContainerViewHeight:(CGFloat)defaultContentContainerViewHeight {
    _defaultContentContainerViewHeight = defaultContentContainerViewHeight;
}
+ (void)setDefaultContentContainerViewWidth:(CGFloat)defaultContentContainerViewWidth {
    _defaultContentContainerViewWidth = defaultContentContainerViewWidth;
}
+ (void)setMinContentContainerViewHeight:(CGFloat)minContentContainerViewHeight {
    _minContentContainerViewHeight = minContentContainerViewHeight;
}
+ (instancetype)shareInstance {
    static dispatch_once_t once;
    static HsProgressHUD *shareView;
    dispatch_once(&once, ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            NSLog(@"HsProgressHUD:window is nil ");
        }
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
    self.centerContainerView = [[UIView alloc] init];
    [self addSubview:self.centerContainerView];
    
    self.contentContainerView = [[UIView alloc] init];
    [self.centerContainerView addSubview:self.contentContainerView];
    
    self.loadingContainerView = [[UIView alloc] init];
    [self.contentContainerView addSubview:self.loadingContainerView];
    
    self.titleView = [[UILabel alloc] init];
    [self.contentContainerView addSubview:self.titleView];
    
    
    self.opearButton = [[UIButton alloc] init];
    [self.centerContainerView addSubview:self.opearButton];
    
    self.lineView = [[UIView alloc] init];
    [self.opearButton addSubview:self.lineView];
    
    [self resetFrame];
}
//初始化样式
- (void)setupStyle {
    self.centerContainerView.backgroundColor = [UIColor blackColor];
    self.centerContainerView.layer.cornerRadius = 4;
    self.centerContainerView.layer.masksToBounds = YES;
    
    self.contentContainerView.backgroundColor = [UIColor clearColor];
    
    self.titleView.font = [UIFont systemFontOfSize:14.0f];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.numberOfLines = 0;
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.textColor = [UIColor whiteColor];
    
    self.opearButton.backgroundColor = [UIColor clearColor];
    
    self.lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.4];
    self.loadingContainerView.backgroundColor = [UIColor clearColor];
    
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
        CGFloat height = _defaultContentContainerViewHeight;
        CGFloat titleHeight = 20;
        if (self.titleView.text.length > 0) {
            CGRect rect= [self.titleView.text boundingRectWithSize:CGSizeMake(_defaultContentContainerViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleView.font} context:nil];
            titleHeight = rect.size.height + 15;
        }
        height += titleHeight;
        
        self.centerContainerView.frame = CGRectMake((self.showInView.frame.size.width-_defaultContentContainerViewWidth)/2, (self.showInView.frame.size.height-height)/2, _defaultContentContainerViewWidth, height);
        self.contentContainerView.frame = CGRectMake(0, 0, self.centerContainerView.frame.size.width-deleteViewWidth, self.centerContainerView.frame.size.height);
        self.loadingContainerView.frame = CGRectMake(0, 0, self.contentContainerView.frame.size.width, self.contentContainerView.frame.size.height-titleHeight);
        self.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(self.loadingContainerView.frame), self.contentContainerView.frame.size.width-titlePadding*2, titleHeight);
        self.opearButton.frame = CGRectMake(CGRectGetMaxX(self.contentContainerView.frame), 0, deleteViewWidth, self.centerContainerView.frame.size.height);
        self.lineView.frame = CGRectMake(0, 0, 1, self.opearButton.frame.size.height);
        [self.opearButton setImage:self.deleteImage forState:UIControlStateNormal];
        self.opearButton.enabled = YES;
    }else if (_status == HsProgressStatusSucess || _status == HsProgressStatusMessage) {
        CGFloat height = 10;
        CGFloat titleHeight = 20;
        if (self.titleView.text.length > 0) {
            CGRect rect= [self.titleView.text boundingRectWithSize:CGSizeMake(_defaultContentContainerViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleView.font} context:nil];
            titleHeight = rect.size.height + 10;
        }
        height += titleHeight;
        height = height < _minContentContainerViewHeight ? _minContentContainerViewHeight : height;
        
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:9 options:0 animations:^{
            self.centerContainerView.frame = CGRectMake((self.showInView.frame.size.width-_defaultContentContainerViewWidth)/2, (self.showInView.frame.size.height-height)/2, _defaultContentContainerViewWidth, height);
            self.contentContainerView.frame = CGRectMake(0, 0, self.centerContainerView.frame.size.width-deleteViewWidth, self.centerContainerView.frame.size.height);
            self.loadingContainerView.frame = CGRectZero;
            self.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(self.loadingContainerView.frame), self.contentContainerView.frame.size.width-titlePadding*2, height);
            self.opearButton.frame = CGRectMake(CGRectGetMaxX(self.contentContainerView.frame), 0, deleteViewWidth, self.centerContainerView.frame.size.height);
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
                CGRect rect= [_weaskSelf.titleView.text boundingRectWithSize:CGSizeMake(_defaultContentContainerViewWidth-deleteViewWidth-titlePadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_weaskSelf.titleView.font} context:nil];
                titleHeight = rect.size.height + 10;
            }
            height += titleHeight;
            height = height < _minContentContainerViewHeight ? _minContentContainerViewHeight : height;
            _weaskSelf.centerContainerView.frame = CGRectMake((_weaskSelf.showInView.frame.size.width-_defaultContentContainerViewWidth)/2, (_weaskSelf.showInView.frame.size.height-height)/2, _defaultContentContainerViewWidth, height);
            _weaskSelf.contentContainerView.frame = CGRectMake(0, 0, _weaskSelf.centerContainerView.frame.size.width-deleteViewWidth, _weaskSelf.centerContainerView.frame.size.height);
            _weaskSelf.loadingContainerView.frame = CGRectZero;
            _weaskSelf.titleView.frame = CGRectMake(titlePadding, CGRectGetMaxY(_weaskSelf.loadingContainerView.frame), _weaskSelf.contentContainerView.frame.size.width-titlePadding*2, height);
            _weaskSelf.opearButton.frame = CGRectMake(CGRectGetMaxX(_weaskSelf.contentContainerView.frame), 0, deleteViewWidth, _weaskSelf.centerContainerView.frame.size.height);
            _weaskSelf.lineView.frame = CGRectMake(0, 0, 1, _weaskSelf.opearButton.frame.size.height);
            if (_status == HsProgressStatusError) {
                [_weaskSelf.opearButton setImage:_weaskSelf.errorImage forState:UIControlStateNormal];
            }else if (_status == HsProgressStatusWarn){
                [_weaskSelf.opearButton setImage:_weaskSelf.warnImage forState:UIControlStateNormal];
            }
        };
        if (_lastStatus == HsProgressStatusLoading) {
            changeFrame();
            [self shakeAnimationForView:self.centerContainerView];
        }else{
             [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:9 options:0 animations:^{
                 changeFrame();
             } completion:^(BOOL finished) {
                [self shakeAnimationForView:self.centerContainerView];
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
    if (self.showStatus == HsProgressStatusDidShow) {
        return;
    }
    self.showStatus = HsProgressStatusDidShow;
    self.status = HsProgressStatusLoading;
    self.titleView.text = title;
    [self.showInView addSubview:self];
    [self resetFrame];
    if (self.loadingView == nil) {
        UIActivityIndicatorView *loadView = [[UIActivityIndicatorView alloc] initWithFrame:self.loadingContainerView.bounds];
        loadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        loadView.center = self.loadingContainerView.center;
        [self.loadingContainerView addSubview:loadView];
        [loadView startAnimating];
    }else{
        self.loadingView.frame = self.loadingContainerView.bounds;
        [self.loadingContainerView addSubview:self.loadingView];
    }
}
- (void)showWithTitle:(NSString *)title status:(HsProgressStatus)status delay:(CGFloat)delay{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self immediatelyDismiss];
    [self clearLoadingView];
    self.status = status;
    self.titleView.text = title;
    [self.showInView addSubview:self];
    self.showStatus = HsProgressStatusDidShow;
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
    [self showWithTitle:title status:HsProgressStatusWarn delay:3.0f];
}

- (void)immediatelyDismiss {
    self.showStatus = HsProgressStatusDidDismiss;
    [self clearLoadingView];
    [self removeFromSuperview];
}
- (void)dismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    self.showStatus = HsProgressStatusWillDismiss;
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
    for (UIView *view in self.loadingContainerView.subviews) {
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
