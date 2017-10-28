//
//  LPTabBar.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/24.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPTabBar.h"
#import "LPBadge.h"

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
    
    for (int i=0; i<self.items.count; i++) {
       [self layoutBadgeAtIndex:i];
    }
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
    LPBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (value && value.length) {
        if (!badge) {
           badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];//添加Badge
        }
        if (value.length > 6) {
            value = [value substringToIndex:6];
        }
        badge.value = value;
        badge.style = LPBadgeStyleValue;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
            badge.tintColor = item.badgeColor;
        }
        [self layoutBadgeAtIndex:item.indexAtTabBar];
    }else {
        [badge removeFromSuperview];//移除原有的Badge
    }
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeColor:(UIColor *)color {
    LPBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    badge.tintColor = color;
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeRedDot:(BOOL)redDot {
    LPBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (redDot) {
        if (!badge) {
            badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];//添加Badge
        }
        badge.style = LPBadgeStyleDot;
        badge.tintColor = [UIColor redColor];
        [self layoutBadgeAtIndex:item.indexAtTabBar];
    }else {
        [badge removeFromSuperview];//移除原有的Badge
    }
}

- (void)tabBarItem:(UITabBarItem *)item didChangedBadgeImage:(UIImage *)image {
    LPBadge *badge = [self badgeAtIndex:item.indexAtTabBar];
    if (image) {
        if (!badge) {
            badge = [self addBadgeForItemAtIndex:item.indexAtTabBar];//添加Badge
        }
        badge.image = image;
        badge.style = LPBadgeStyleImage;
        [self layoutBadgeAtIndex:item.indexAtTabBar];
    }else {
        [badge removeFromSuperview];//移除原有的Badge
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
- (CGFloat)originXOfBadgeAtIndex:(NSInteger)index {
    CGFloat itemWidth = self.bounds.size.width/self.items.count;
    CGFloat badgeX = (index+0.5) * itemWidth + 5;
    return badgeX;
}

//获取在指定BarItem上的Badge
- (LPBadge *)badgeAtIndex:(NSInteger)index {
    LPBadge *badge = [self.tabBarView viewWithTag:BADGE_BASE_TAG+index];
    return badge;
}

//给指定BarItem添加Badge
- (LPBadge *)addBadgeForItemAtIndex:(NSInteger)index {
    LPBadge *badge = [LPBadge new];
    badge.tag = BADGE_BASE_TAG + index;
    CGFloat x = [self originXOfBadgeAtIndex:index];
    badge.frame = CGRectMake(x, 2, 0, 0);
    [self.tabBarView addSubview:badge];
    return badge;
}

//重置badges的布局
- (void)layoutBadgeAtIndex:(NSInteger)index {
    LPBadge *badge = [self badgeAtIndex:index];
    CGFloat x = [self originXOfBadgeAtIndex:index];
    CGSize size = badge.frame.size;
    badge.frame = CGRectMake(x, 12-size.height/2.0f, size.width, size.height);
}

@end
