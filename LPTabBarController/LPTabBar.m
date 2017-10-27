//
//  LPTabBar.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/24.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPTabBar.h"
#import "LPTabBarBadge.h"

#define BADGE_BASE_TAG 50


@interface LPTabBar ()
{
    __weak IBOutlet UIView *centerItemBaseView;//中间选项视图
}
@property (assign, nonatomic) NSInteger touchBeganIndex;//点击开始选项
@property (weak, nonatomic) UIView *tabBarView;//自定义TabBar层
@end


@implementation LPTabBar
#pragma mark - ------------------------ 重写 --------------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView *tabBar = [NSBundle.mainBundle loadNibNamed:@"LPTabBarView" owner:self options:nil].firstObject;
        [self addSubview:tabBar];
        self.tabBarView = tabBar;
        
        self.barTintColor = [UIColor whiteColor];
        [self updateCenterItemHidden];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tabBarView.frame = self.bounds;
    [self bringSubviewToFront:self.tabBarView];
}


- (void)setViewDelegate:(id<LPTabBarViewDelegate>)viewDelegate {
    self.delegate = viewDelegate;
    _viewDelegate = viewDelegate;
}


- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    centerItemBaseView.backgroundColor = barTintColor;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL centerItemHidden = self.centerItemImgView.hidden;
    BOOL inCenterItem = CGRectContainsPoint(self.centerItemImgView.frame, point);
    if (!centerItemHidden && inCenterItem) {
        return self;
    }else {
        return [super hitTest:point withEvent:event];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchBeganIndex = [self indexWithTouch:touches.anyObject];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //点击结束
    if ([self.viewDelegate respondsToSelector:@selector(tabBar:didSelectIndex:)]) {
        NSInteger index = [self indexWithTouch:touches.anyObject];
        if (index>=0 && self.touchBeganIndex>=0 && index == self.touchBeganIndex) {
            [self.viewDelegate tabBar:self didSelectIndex:index];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchBeganIndex = -1;
}




#pragma mark - <LPTabBarItemDelegate>协议实现
- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeValue:(NSString *)value {
    LPTabBarBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (value && value.length) {
        if (!badge) {
            //添加Badge
           badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];
        }
        badge.value = value;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            badge.tintColor = item.badgeColor;
        }
    }else {
        //移除原有的Badge
        [badge removeFromSuperview];
    }
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeColor:(UIColor *)color {
    LPTabBarBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    badge.tintColor = color;
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeRedDot:(BOOL)redDot {
    LPTabBarBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (redDot) {
        if (!badge) {
            //添加Badge
            badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];
        }
        badge.redDot = redDot;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            badge.tintColor = item.badgeColor;
        }
    }else {
        //移除原有的Badge
        [badge removeFromSuperview];
    }
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeImage:(UIImage *)image {
    LPTabBarBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (image) {
        if (!badge) {
            //添加Badge
            badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];
        }
        badge.image = image;
    }else {
        //移除原有的Badge
        [badge removeFromSuperview];
    }
}





#pragma mark - ------------------------ 外部方法 --------------------------
- (void)updateCenterItemHidden {
    BOOL fiveItems = self.items.count==BarItemCriterionCount;
    BOOL hasCenterImg = self.centerItemImgView.image || self.centerItemImgView.highlightedImage;
    BOOL hidden = !(fiveItems && hasCenterImg);
    centerItemBaseView.hidden = hidden;
    self.centerItemImgView.hidden = hidden;
}





#pragma mark - 辅助方法
//获取点击的选项索引，Bar外部为-1。
- (NSInteger)indexWithTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    BOOL inCenterItem = CGRectContainsPoint(self.centerItemImgView.frame, point);
    BOOL inSelf = CGRectContainsPoint(self.bounds, point);
    if (inCenterItem || inSelf) {
        CGFloat itemWidth = self.bounds.size.width/(CGFloat)(self.items.count);
        NSInteger index = point.x / itemWidth;
        return index;
    }else {
        return -1;
    }
}


//获取Badge中心位置
- (CGPoint)centerOfBadgeAtIndex:(NSInteger)index {
    CGFloat itemWidth = self.bounds.size.width/self.items.count;
    CGFloat badgeCenterX = (index+0.5) * itemWidth + 15;
    return CGPointMake(badgeCenterX, 12);
}

//获取在指定BarItem上的Badge
- (LPTabBarBadge *)badgeAtIndex:(NSInteger)index {
    LPTabBarBadge *badge = [self.tabBarView viewWithTag:BADGE_BASE_TAG+index];
    return badge;
}

//给指定BarItem添加Badge
- (LPTabBarBadge *)addBadgeForItemAtIndex:(NSInteger)index {
    LPTabBarBadge *badge = [LPTabBarBadge new];
    badge.tag = BADGE_BASE_TAG + index;
    badge.center = [self centerOfBadgeAtIndex:index];
    [self.tabBarView addSubview:badge];
    return badge;
}


@end
