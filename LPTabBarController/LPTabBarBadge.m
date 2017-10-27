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
///小红点直径
const CGFloat RedDotWide = 8;
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
    //标签
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.clipsToBounds = YES;
    valueLabel.font = [UIFont systemFontOfSize:11];
    valueLabel.textColor = [UIColor whiteColor];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
    
    //图片容器
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = NO;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    //其它
    self.clipsToBounds = NO;
    self.tintColor = [UIColor redColor];
    self.wide = 18;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //有效内容尺寸
    CGSize size = CGSizeZero;
    if (self.value && self.value.length) {
        [self.valueLabel sizeToFit];
        CGFloat width = MAX(self.valueLabel.bounds.size.width + 10, self.wide);
        size = CGSizeMake(width, self.wide);
    }else if (self.redDot) {
        size = CGSizeMake(RedDotWide, RedDotWide);
    }else if (self.image) {
        size = self.image.size;
    }else {
        size = CGSizeZero;
    }
    
    //self尺寸位置
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, MAX(size.width, MinWide), MAX(size.height, MinWide));
    self.center = center;
    CGPoint centerP = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    //valueLabel
    self.valueLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    self.valueLabel.layer.cornerRadius = size.height/2.0f;
    self.valueLabel.center = centerP;
    
    //imageView
    self.imageView.center = centerP;
}


#pragma mark - ------------------------ Setter&Getter --------------------------
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = [tintColor copy];
    self.valueLabel.backgroundColor = tintColor?:[UIColor redColor];
}

- (void)setWide:(CGFloat)wide {
    _wide = wide;
    [self layoutSubviews];
}

- (void)setValue:(NSString *)value {
    _redDot = NO;
    self.valueLabel.text = value;
    self.imageView.image = nil;
    [self layoutSubviews];
    self.valueLabel.hidden = !(value&&value.length);
}

- (void)setRedDot:(BOOL)redDot {
    _redDot = redDot;
    self.valueLabel.text = nil;
    self.imageView.image = nil;
    [self layoutSubviews];
    self.valueLabel.hidden = !redDot;
}

- (void)setImage:(UIImage *)image {
    _redDot = NO;
    self.valueLabel.text = nil;
    self.imageView.image = image;
    [self layoutSubviews];
    self.valueLabel.hidden = YES;
}

- (NSString *)value {
    return self.valueLabel.text;
}

- (UIImage *)image {
    return self.imageView.image;
}

@end
