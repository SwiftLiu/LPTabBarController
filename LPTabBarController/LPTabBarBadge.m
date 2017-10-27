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
{
    CGPoint touchBeganPoint;
}
@property (weak, nonatomic) UILabel *valueLabel;
@property (weak, nonatomic) UIImageView *imageView;
@end


@implementation LPTabBarBadge
#pragma mark - ------------------------ 初始化、重写 --------------------------
- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleWipe) object:nil];
}

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
    imageView.animationDuration = .25;
    imageView.animationRepeatCount = 1;
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




//MARK: 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self];
    touchBeganPoint = p;
    NSLog(@"触摸开始：(%lf,%lf)", p.x, p.y);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self];
    NSLog(@"触摸移动：(%lf,%lf)", p.x, p.y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self];
    if (CGPointEqualToPoint(touchBeganPoint, p)) {
        [self wipe];
    }
    NSLog(@"触摸结束：(%lf,%lf)", p.x, p.y);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self];
    NSLog(@"触摸取消：(%lf,%lf)", p.x, p.y);
}



#pragma mark - ------------------------ 动画 --------------------------
//MARK: 擦除动画
- (void)wipe {
    //添加动画帧
    if (!self.imageView.animationImages) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i=1; i<=5; i++) {
            NSString *imgName = [NSString stringWithFormat:@"LPTabBarBadge.bundle/LPBadgeBomb_%d", i];
            UIImage *img = [UIImage imageNamed:imgName];
            if (img) {
                [images addObject:img];
            }
        }
        self.imageView.animationImages = images;
    }
    //执行动画
    self.valueLabel.hidden = YES;
    [self.imageView startAnimating];
    
    //动画结束处理
    [self performSelector:@selector(handleWipe) withObject:nil afterDelay:self.imageView.animationDuration];
}

- (void)handleWipe {
    
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
