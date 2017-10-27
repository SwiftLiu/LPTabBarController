//
//  UITabBarItem+LPTabBarItem.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/26.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "UITabBarItem+LPTabBarItem.h"
#import <objc/runtime.h>

@implementation UITabBarItem (LPTabBarItem)
#pragma mark - ------------------------ 属性Setter&Getter --------------------------
static const char LPTabBarItemDelegateKey = '\0';
- (void)setDelegate:(id<LPTabBarItemDelegate>)delegate {
    if (delegate != self.delegate) {
        [self willChangeValueForKey:@"delegate"]; // KVO
        objc_setAssociatedObject(self, &LPTabBarItemDelegateKey,
                                 delegate, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"delegate"]; // KVO
    }
}

- (id<LPTabBarItemDelegate>)delegate {
    return objc_getAssociatedObject(self, &LPTabBarItemDelegateKey);
}



static const char LPTabBarItemIndex = '\0';
- (void)setIndexAtTabBar:(NSInteger)indexAtTabBar {
    [self willChangeValueForKey:@"indexAtTabBar"]; // KVO
    objc_setAssociatedObject(self, &LPTabBarItemIndex,
                             @(indexAtTabBar), OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"indexAtTabBar"]; // KVO
}

- (NSInteger)indexAtTabBar {
    return [objc_getAssociatedObject(self, &LPTabBarItemIndex) integerValue];
}




#pragma mark - ------------------------ 重写 --------------------------
- (void)setBadgeValue:(NSString *)badgeValue {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarItem:didChangedBadgeValue:)]) {
        [self.delegate tabBarItem:self didChangedBadgeValue:badgeValue];
    }
}
- (void)setBadgeColor:(UIColor *)badgeColor {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarItem:didChangedBadgeColor:)]) {
        [self.delegate tabBarItem:self didChangedBadgeColor:badgeColor];
    }
}
@end
