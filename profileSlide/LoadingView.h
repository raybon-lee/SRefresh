//
//  LoadingView.h
//  profileSlide
//
//  Created by S on 15/10/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic,assign) BOOL isLoading;

+ (instancetype)share;

/**
 *
 *  开启加载
 *
 */
- (void)startLoading;

/**
 *
 *  开启加载
 *  view
 *
 */
- (void)startLoadingWithView:(UIView *)view;

/**
 *
 *  关闭加载
 *
 */
- (void)stopLoading;


@end


@interface PullLoadingView : UIView

@property (nonatomic,assign) BOOL isPullLoading;

+ (instancetype)share;

/**
 *
 *  开启加载
 *  view
 *  progress
 *
 */
- (void)startPullLoadingWithView:(UIView *)view withPullDistance:(CGFloat)distance;

/**
 *
 *  关闭加载
 *
 */
- (void)stopLoading;

@end




