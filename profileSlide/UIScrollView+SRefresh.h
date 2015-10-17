//
//  UIScrollView+SRefresh.h
//  profileSlide
//
//  Created by S on 15/10/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Pull = 0,
    Push,
}PanState;

typedef void(^SRefreshBlock)(PanState state);


@interface UIScrollView (SRefresh)

/**
 *
 *  添加下拉刷新
 *
 */
- (void)addRefreshBlock:(SRefreshBlock)completion;


/**
 *
 *  停止刷新动画
 *
 */
- (void)stopRefresh;

@end
