//
//  MainTabBarController.m
//  Lart
//
//  Created by iOSLiu on 2017/3/7.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "MainTabBarController.h"


@interface MainTabBarController ()
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *homeVC = [[UIViewController alloc] init];
    UIViewController *findVC = [[UIViewController alloc] init];
    UIViewController *funyVC = [[UIViewController alloc] init];
    UIViewController *schlVC = [[UIViewController alloc] init];
    UIViewController *mineVC = [[UIViewController alloc] init];
    
    homeVC.title = @"首页";
    findVC.title = @"课程";
    funyVC.title = @"玩艺录";
    schlVC.title = @"社区";
    mineVC.title = @"我的";
    
    homeVC.tabBarItem.title = @"首页";
    findVC.tabBarItem.title = @"课程";
    funyVC.tabBarItem.title = @"玩艺录";
    schlVC.tabBarItem.title = @"社区";
    mineVC.tabBarItem.title = @"我的";
    
    homeVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_home"];
    findVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_find"];
    funyVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_funny"];
    schlVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_school"];
    mineVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_mine"];
    
    [homeVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabBar_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [findVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabBar_find_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [funyVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabBar_funny_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [schlVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabBar_school_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [mineVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabBar_mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UINavigationController *findNav = [[UINavigationController alloc] initWithRootViewController:findVC];
    UINavigationController *funyNav = [[UINavigationController alloc] initWithRootViewController:funyVC];
    UINavigationController *schlNav = [[UINavigationController alloc] initWithRootViewController:schlVC];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    
    homeNav.navigationBarHidden = NO;
    findNav.navigationBarHidden = NO;  
    funyNav.navigationBarHidden = NO;
    schlNav.navigationBarHidden = NO;
    mineNav.navigationBarHidden = NO;
    
    self.tabBar.tintColor = [UIColor colorWithRed:29/255.f green:93/255.f blue:167/255.f alpha:1];
    self.tabBar.translucent = NO;
    [self setViewControllers:@[homeNav, findNav, funyNav, schlNav, mineNav]];
    
    //设置中间大图
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSData *data = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"centerItem.gif"]];
    [self setCenterItemGifImageData:data];
    
    //设置BadgeValue
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        homeVC.tabBarItem.badgeValue = @"8";
        findVC.tabBarItem.badgeValue = @"new";
        schlVC.tabBarItem.badgeImage = [UIImage imageNamed:@"badge.png"];
        mineVC.tabBarItem.badgeRedDot = YES;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        mineVC.tabBarItem.badgeValue = @"8";
        schlVC.tabBarItem.badgeValue = @"new";
        findVC.tabBarItem.badgeImage = [UIImage imageNamed:@"badge.png"];
        homeVC.tabBarItem.badgeRedDot = YES;
    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        mineVC.tabBarItem.badgeValue = @"";
//        schlVC.tabBarItem.badgeValue = nil;
//        findVC.tabBarItem.badgeImage = nil;
//        homeVC.tabBarItem.badgeRedDot = NO;
//    });
}


@end
