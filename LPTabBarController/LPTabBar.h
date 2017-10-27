//
//  LPTabBar.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/24.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarItem+LPTabBarItem.h"


/** 协议 */
@protocol LPTabBarViewDelegate <UITabBarDelegate>
@required
/** 点击选项时 */
- (void)tabBar:(UITabBar *)tabBar didSelectIndex:(NSInteger)index;
@end



#define BarItemCriterionCount 5

/*************** 自定义TabBar ***************/
@interface LPTabBar : UITabBar <LPTabBarItemDelegate>
///中间选项图片容器
@property (weak, nonatomic) IBOutlet UIImageView *centerItemImgView;
///代理
@property (weak, nonatomic) id <LPTabBarViewDelegate> viewDelegate;

/** 刷新中间选项大图隐藏 */
- (void)updateCenterItemHidden;
@end
