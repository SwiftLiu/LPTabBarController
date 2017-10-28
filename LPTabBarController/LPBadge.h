//
//  LPBadge.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/28.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LPBadgeStyle) {
    ///字符串圆圈风格
    LPBadgeStyleValue,
    ///小圆点风格
    LPBadgeStyleDot,
    ///自定义图片风格
    LPBadgeStyleImage
};


/*************** 自定义Badge ***************/
@interface LPBadge : UIView
///风格
@property (assign, nonatomic) LPBadgeStyle style;

///字符串
@property (copy, nonatomic) NSString *value;
///字符串风格时Badge直径，默认为18
@property (assign, nonatomic) CGFloat wide;
///主色彩，默认为红色(255,0,0)
@property (copy, nonatomic) UIColor *tintColor;
///图片
@property (copy, nonatomic) UIImage *image;

///擦除时处理
@property (copy, nonatomic) void (^wipeHandler)(void);

/** 擦除Badge */
- (void)wiped;
@end
