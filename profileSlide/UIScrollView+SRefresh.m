//
//  UIScrollView+SRefresh.m
//  profileSlide
//
//  Created by S on 15/10/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import "UIScrollView+SRefresh.h"
#import <objc/runtime.h>
#import "LoadingView.h"


typedef enum{
    WillLoading = 0,
    PullIsLoading ,
    PushIsLoading ,
}RefreshState;


static RefreshState refreshState = WillLoading;

@interface UILabel (refresh)

+ (instancetype)share;

@end

@implementation UILabel (refresh)

+ (instancetype)share {
    static UILabel * label;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        label = [[UILabel alloc] init];
    });
    return label;
}

@end



#define ContentOfSet @"contentOffset"

#define PullWillLoadingTitle @"下拉即可刷新..."
#define PullIsLoadingTitle @"正在刷新..."
#define PushDeadLine 20

static char RefreshBlockKey;

@implementation UIScrollView (SRefresh)

#pragma mark - 添加刷新
- (void)addRefreshBlock:(SRefreshBlock)completion {
    
    objc_setAssociatedObject(self, &RefreshBlockKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 添加监听
    [self addObserver:self forKeyPath:ContentOfSet options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


#pragma mark - 监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    CGPoint new = [[change objectForKey:@"new"] CGPointValue];
    CGPoint old = [[change objectForKey:@"old"] CGPointValue];
    if (new.y == old.y) return;
    
    if (new.y <= 0) {
        // 下拉逻辑
        [self pullRefreshWithChange:change];
    }else {
        // 上拉逻辑
        [self pushRefreshWithChange:change];
    }
}

#pragma mark - 下拉
- (void)pullRefreshWithChange:(NSDictionary *)change {
    /**
     charge = @{kind:@"",new:@"",old:@""}
     */
    CGPoint new = [[change objectForKey:@"new"] CGPointValue];
    
    SRefreshBlock headerBlock = objc_getAssociatedObject(self, &RefreshBlockKey);
    
    // 文字
    UILabel * titleLabel = [UILabel share];
    titleLabel.frame = CGRectMake(self.center.x-15, -35, 120, 30);
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:titleLabel];
    
    // 动画
    PullLoadingView * loading = [PullLoadingView share];
    loading.frame = CGRectMake(self.center.x-30-30, -35, 30, 30);
    
    titleLabel.text = loading.isPullLoading ? PullIsLoadingTitle : PullWillLoadingTitle;
    
    if (new.y<0) {
        [loading startPullLoadingWithView:self withPullDistance:new.y];
        if (!self.dragging && loading.isPullLoading && refreshState == WillLoading) {
            
            refreshState = PullIsLoading;
            [UIView animateWithDuration:0.25 animations:^{
                self.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
            } completion:^(BOOL finished) {
                
            }];
            
            headerBlock(Pull);
        }
    }
    
    if (self.contentOffset.y == 0) {
        [loading stopLoading];
    }

}

#pragma mark - 上拉
- (void)pushRefreshWithChange:(NSDictionary *)change {
    /**
     charge = @{kind:@"",new:@"",old:@""}
     */
    CGPoint new = [[change objectForKey:@"new"] CGPointValue];
    CGPoint old = [[change objectForKey:@"old"] CGPointValue];
    
    SRefreshBlock footerBlock = objc_getAssociatedObject(self, &RefreshBlockKey);
    
    /**
     超过警戒线开始加载更多数据
     */
    if (new.y >= self.contentSize.height-self.frame.size.height-PushDeadLine && new.y>old.y && refreshState == WillLoading) {
        refreshState = PushIsLoading;
        footerBlock(Push);
    }
}

#pragma mark - 停止刷新
- (void)stopRefresh {
    refreshState = WillLoading;
    [UIView animateWithDuration:0.25 animations:^{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
    PullLoadingView * loading = [PullLoadingView share];
    [loading stopLoading];
}


@end


