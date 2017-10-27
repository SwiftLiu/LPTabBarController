//
//  LPTabBarBadge.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/26.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPTabBarBadge.h"

///最小边长
const CGFloat MinWide = 30;
///可回弹的最大半径
const CGFloat ElsticMaxR = 55;

@interface LPTabBarBadge ()
@property (weak, nonatomic) UILabel *valueLabel;
@property (weak, nonatomic) UIImageView *imageView;
@end


@implementation LPTabBarBadge
#pragma mark - ------------------------ 初始化、重写 --------------------------
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 30, 30);
        [self initBaseView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initBaseView];
}

//初始化
- (void)initBaseView {
    
    //设置默认值
    self.tintColor = [UIColor redColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //self
    CGPoint center = self.center;
    CGSize size = self.valueLabel.bounds.size;
    self.bounds = CGRectMake(0, 0, MAX(size.width, MinWide), MAX(size.height, MinWide));
    self.center = center;
    
    //valueLabel
    
    
    //imageView
}


#pragma mark - ------------------------ Setter&Getter --------------------------



@end
