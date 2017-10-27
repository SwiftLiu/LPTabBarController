//
//  LPTabBarController.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/24.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPTabBarController.h"
#import "LPTabBar.h"
#import "UIImage+GifImage.h"
#import <objc/runtime.h>

@interface LPTabBarController ()<LPTabBarViewDelegate>
@property (strong, nonatomic, readonly) LPTabBar *tabBarView;
@end

@implementation LPTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 利用 KVC 来使用自定义的tabBar；
    _tabBarView = [[LPTabBar alloc] init];
    _tabBarView.viewDelegate = self;
    [_tabBarView updateCenterItemHidden];
    [self setValue:_tabBarView forKey:@"tabBar"];
}



- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [self.tabBarView updateCenterItemHidden];
    for (int i=0; i<viewControllers.count; i++) {
        UIViewController *vc = [viewControllers objectAtIndex:i];
        vc.tabBarItem.delegate = self.tabBarView;
        vc.tabBarItem.indexAtTabBar = i;//索引
    }
    [super setViewControllers:viewControllers];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    self.tabBarView.centerItemImgView.highlighted = selectedIndex == 2;
}




#pragma mark - ------------------------ 外部方法 --------------------------
- (void)setCenterItemImage:(UIImage *)image {
    __weak UIImageView *imgView = self.tabBarView.centerItemImgView;
    imgView.image = image;
    if (!imgView.highlightedImage) {
        imgView.highlightedImage = image;
    }
    [self.tabBarView updateCenterItemHidden];
}

- (void)setCenterItemSelectedImage:(UIImage *)image {
    __weak UIImageView *imgView = self.tabBarView.centerItemImgView;
    imgView.highlightedImage = image;
    if (!imgView.image) {
        imgView.image = image;
    }
    [self.tabBarView updateCenterItemHidden];
}

- (void)setCenterItemGifImageData:(NSData *)data {
    __weak UIImageView *imgView = self.tabBarView.centerItemImgView;
    imgView.image = [UIImage gifImageWithData:data];
    if (!imgView.highlightedImage) {
        imgView.highlightedImage = [UIImage firstFrameOfGifImageData:data];
    }
    [self.tabBarView updateCenterItemHidden];;
}

- (void)setCenterItemSelectedGifImageData:(NSData *)data {
    __weak UIImageView *imgView = self.tabBarView.centerItemImgView;
    imgView.highlightedImage = [UIImage gifImageWithData:data];
    if (!imgView.image) {
        imgView.image = [UIImage firstFrameOfGifImageData:data];
    }
    [self.tabBarView updateCenterItemHidden];;
}



#pragma mark - <LPTabBarViewDelegate>协议实现
- (void)tabBar:(UITabBar *)tabBar didSelectIndex:(NSInteger)index {
    self.selectedIndex = index;
}
@end






#pragma mark - ------------------------ UITabBarItem类目 --------------------------
@implementation UITabBarItem (TabBarItemBadgeImage)
#pragma mark - ------------------------ 属性Setter&Getter --------------------------
static const char TabBarItemBadgeImageKey = '\0';
- (void)setBadgeImage:(UIImage *)badgeImage {
    if (badgeImage != self.badgeImage) {
        // 存储新的
        [self willChangeValueForKey:@"badgeImage"]; // KVO
        objc_setAssociatedObject(self, &TabBarItemBadgeImageKey,
                                 badgeImage, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"badgeImage"]; // KVO
        
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarItem:didChangedBadgeImage:)]) {
            [self.delegate tabBarItem:self didChangedBadgeImage:badgeImage];
        }
    }
}
- (UIImage *)badgeImage {
    return objc_getAssociatedObject(self, &TabBarItemBadgeImageKey);
}



- (void)setBadgeGifData:(NSData *)badgeGifData {
    //代理回调
    [self setBadgeImage:[UIImage gifImageWithData:badgeGifData]];
}




static const char TabBarItemBadgeRedDot = '\0';
- (void)setBadgeRedDot:(BOOL)badgeRedDot {
    [self willChangeValueForKey:@"badgeRedDot"]; // KVO
    objc_setAssociatedObject(self, &TabBarItemBadgeRedDot,
                             @(badgeRedDot), OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"badgeRedDot"]; // KVO
    
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarItem:didChangedBadgeRedDot:)]) {
        [self.delegate tabBarItem:self didChangedBadgeRedDot:badgeRedDot];
    }
}

- (BOOL)badgeRedDot {
    return [objc_getAssociatedObject(self, &TabBarItemBadgeRedDot) integerValue];
}
@end
