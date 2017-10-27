//
//  LPTabBarController.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/24.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

/*************** 自定义TabBarController ***************/
@interface LPTabBarController : UITabBarController
/** 中间选项图片数据（仅适用于5选项时的TabBar） */
- (void)setCenterItemImage:(UIImage *)image;
/** 中间选项选中时图片数据（仅适用于5选项时的TabBar） */
- (void)setCenterItemSelectedImage:(UIImage *)image;

/** 中间选项GIF图片数据（仅适用于5选项时的TabBar） */
- (void)setCenterItemGifImageData:(NSData *)data;
/** 中间选项选中时GIF图片数据（仅适用于5选项时的TabBar） */
- (void)setCenterItemSelectedGifImageData:(NSData *)data;
@end



@interface UITabBarItem (TabBarItemBadgeImage)
///Badge显示为小红点
@property (assign, nonatomic) BOOL badgeRedDot;
///Badge图片
@property (strong, nonatomic) UIImage *badgeImage;
/** Badge图片数据（支持GIF） */
- (void)setBadgeGifData:(NSData *)badgeGifData;
@end
