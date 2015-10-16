//
//  LoadingView.m
//  profileSlide
//
//  Created by S on 15/10/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import "LoadingView.h"
#import "AppDelegate.h"


#define ANGLE(angle) ((M_PI*angle)/180)

#define RotationAnimation @"rotationAnimation"


static CAShapeLayer * subLayer;

@implementation LoadingView


+ (instancetype)share {
    static LoadingView * view;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        view = [[LoadingView alloc] init];
    });
    return view;
}


#pragma mark - 开启加载
- (void)startLoading {
    AppDelegate * appdelegate = [[UIApplication sharedApplication] delegate];
    [self startLoadingWithView:appdelegate.window];
}

#pragma mark - 开启加载 withView
- (void)startLoadingWithView:(UIView *)view {
    // 半径
    CGFloat radius = self.frame.size.width/2;
    
    // 画圆
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(radius*2, radius)];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:ANGLE(330) clockwise:YES];
    path.lineWidth = 2;
    path.lineCapStyle = kCGLineCapRound;
    [path stroke];
    
    // 渲染
    subLayer = [CAShapeLayer layer];
    subLayer.path = path.CGPath;
    subLayer.strokeColor = [UIColor grayColor].CGColor;
    subLayer.fillColor = [UIColor clearColor].CGColor;
    subLayer.strokeStart = 0;
    subLayer.strokeEnd = 0;
    subLayer.lineWidth = 2;
    
    // 画线动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0];
    pathAnimation.toValue = [NSNumber numberWithFloat:1];
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [subLayer addAnimation:pathAnimation forKey:nil];
    
    // 旋转动画
    CABasicAnimation * rotaion = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotaion.duration = 1;
    rotaion.removedOnCompletion = NO;
    rotaion.fillMode = kCAFillModeForwards;
    rotaion.repeatCount = 100;
    rotaion.toValue = [NSNumber numberWithFloat:M_PI*2];
    [self.layer addAnimation:rotaion forKey:RotationAnimation];
    
    [self.layer addSublayer:subLayer];
    
    [view addSubview:self];
}

#pragma mark - 关闭加载
- (void)stopLoading {
    // 移除旋转动画
    [self.layer removeAnimationForKey:RotationAnimation];
    [subLayer removeFromSuperlayer];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


static CAShapeLayer * pullLayer;

// 最大下拉距离
#define MaxPullDistance -100.0
static BOOL isLoading = NO;

@implementation PullLoadingView

+ (instancetype)share {
    static PullLoadingView * view;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        view = [[PullLoadingView alloc] init];
    });
    return view;
}

#pragma mark - 开启
- (void)startPullLoadingWithView:(UIView *)view withPullDistance:(CGFloat)distance {
    
    if (!isLoading) {
        // 半径
        CGFloat radius = self.frame.size.width/2;
        pullLayer.path = nil;
        // 画圆
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(radius*2, radius)];
        CGFloat angle = distance<MaxPullDistance ? 330:(distance *330)/MaxPullDistance;
        CGFloat angle1 = angle>0 ?angle:0;
        [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:ANGLE(angle1) clockwise:YES];
        path.lineWidth = 2;
        path.lineCapStyle = kCGLineCapRound;
        [path stroke];
        
        // 渲染
        pullLayer = [CAShapeLayer layer];
        pullLayer.path = path.CGPath;
        pullLayer.strokeColor = [UIColor grayColor].CGColor;
        pullLayer.fillColor = [UIColor clearColor].CGColor;
        pullLayer.strokeStart = 0;
        pullLayer.strokeEnd = 1;
        pullLayer.lineWidth = 2;
        
        
        // 超过下拉警戒线后，开启旋转
        if (distance < MaxPullDistance) {
            // 旋转动画
            CABasicAnimation * rotaion = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotaion.duration = 1;
            rotaion.removedOnCompletion = NO;
            rotaion.fillMode = kCAFillModeForwards;
            rotaion.repeatCount = 100;
            rotaion.toValue = [NSNumber numberWithFloat:M_PI*2];
            [self.layer addAnimation:rotaion forKey:RotationAnimation];
            isLoading = YES;
        }
        
        if (![pullLayer.superlayer isEqual:self.layer]) {
            [self.layer addSublayer:pullLayer];
        }
        
        [view addSubview:self];

    }
}

#pragma mark - 关闭
- (void)stopLoading {
    // 移除旋转动画
    [self.layer removeAnimationForKey:RotationAnimation];
    isLoading = NO;
    
}

@end









