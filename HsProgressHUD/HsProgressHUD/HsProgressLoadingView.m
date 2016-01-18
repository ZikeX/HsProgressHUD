//
//  HsProgressLoadingView.m
//  HsProgressHUD
//
//  Created by 王金东 on 16/1/15.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsProgressLoadingView.h"

@interface HsProgressLoadingView ()
@end

@implementation HsProgressLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoading) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
     [self replicatorLayer];
}

- (void)showLoading {
    [self replicatorLayer];
}
- (void)replicatorLayer {
    
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    
    CGRect replicatorRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = replicatorRect;
   // replicatorLayer.anchorPoint = CGPointMake(0, 0);
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:replicatorLayer];
    
    
    CALayer *rectangle = [CALayer layer];
    rectangle.bounds = CGRectMake(0,0,30,90);
    rectangle.anchorPoint = CGPointMake(0, 0);
    rectangle.position = CGPointMake(20, 80);
    rectangle.cornerRadius = 2;
    rectangle.backgroundColor = [UIColor whiteColor].CGColor;
    [replicatorLayer addSublayer:rectangle];
    //    let moveRectangle = CABasicAnimation(keyPath: "position.y")
    //    moveRectangle.toValue = rectangle.position.y - 70
    //    moveRectangle.duration = 0.7
    //    moveRectangle.autoreverses = true
    //    moveRectangle.repeatCount = HUGE
    //    rectangle.addAnimation(moveRectangle, forKey: nil)
    CABasicAnimation *moveRectangle = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveRectangle.toValue = @(rectangle.position.y - 70);
    moveRectangle.duration = 0.7;
    moveRectangle.autoreverses = YES;
    moveRectangle.repeatCount = MAXFLOAT;
    [rectangle addAnimation:moveRectangle forKey:nil];
    
    //复制3份
    replicatorLayer.instanceCount = 3;
    //距离间隔
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(40, 0, 0);
    //递归延迟
    replicatorLayer.instanceDelay = 0.3;
    //遮罩
    replicatorLayer.masksToBounds = YES;
}
@end
