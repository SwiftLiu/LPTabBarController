//
//  LPTabBarBadge.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/26.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

/*************** 自定义徽章 ***************/
@interface LPTabBarBadge : UIView
///值（value、redDot和image三种效果只能同时展示一种）
@property (copy, nonatomic) NSString *value;
///小圆点效果（value、redDot和image三种效果只能同时展示一种）
@property (assign, nonatomic) BOOL redDot;
///图片（value、redDot和image三种效果只能同时展示一种）
@property (copy, nonatomic) UIImage *image;


///主色彩，默认为红色(255,0,0)
@property (copy, nonatomic) UIColor *tintColor;
///value半径，默认为20
@property (assign, nonatomic) CGFloat radius;
@end
