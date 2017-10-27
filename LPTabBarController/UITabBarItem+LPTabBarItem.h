//
//  UITabBarItem+LPTabBarItem.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/26.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 协议 */
@protocol LPTabBarItemDelegate <NSObject>
@optional
/** 设置Badge值时 */
- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeValue:(NSString *)value;
/** 设置Badge小红点状态 */
- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeRedDot:(BOOL)redDot;
/** 设置Badge背景色时 */
- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeColor:(UIColor *)color;
/** 设置Badge图片时 */
- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeImage:(UIImage *)image;
@end


@interface UITabBarItem (LPTabBarItem)
///代理
@property (weak, nonatomic) id <LPTabBarItemDelegate> delegate;
///索引
@property (assign, nonatomic) NSInteger indexAtTabBar;
@end
