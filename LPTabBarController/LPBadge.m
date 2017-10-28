//
//  LPBadge.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/28.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPBadge.h"

///最小边长
const CGFloat MinWide = 30;
///小红点直径
const CGFloat RedDotWide = 8;
///可回弹的最大半径
const CGFloat ElsticMaxR = 55;

@interface LPBadge ()
{
    CGPoint touchBeganPoint;
}
@property (weak, nonatomic) UILabel *valueLabel;
@property (weak, nonatomic) UIImageView *imageView;
@end


@implementation LPBadge
#pragma mark - ------------------------ 初始化、重写 --------------------------
- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleWipe) object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, MinWide, MinWide);
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
    valueLabel.hidden = YES;
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
    
    //图片容器
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = NO;
    imageView.hidden = YES;
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
    if (self.style == LPBadgeStyleValue) {
        [self.valueLabel sizeToFit];
        CGFloat width = MAX(self.valueLabel.bounds.size.width + 8, self.wide);
        size = CGSizeMake(width, self.wide);
    }else if (self.style == LPBadgeStyleDot) {
        size = CGSizeMake(RedDotWide, RedDotWide);
    }else if (self.style == LPBadgeStyleImage) {
        size = self.image.size;
    }
    
    //self尺寸位置
    CGPoint center = self.center;
    self.bounds = CGRectMake(0, 0, MAX(size.width, MinWide), MAX(size.height, MinWide));
    self.center = center;
    CGPoint centerP = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    //valueLabel尺寸位置
    self.valueLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    self.valueLabel.layer.cornerRadius = size.height/2.0f;
    self.valueLabel.center = centerP;
    
    //imageView尺寸位置
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
        [self wiped];
    }
    NSLog(@"触摸结束：(%lf,%lf)", p.x, p.y);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self];
    NSLog(@"触摸取消：(%lf,%lf)", p.x, p.y);
}



#pragma mark - ------------------------ 动画 --------------------------
//MARK: 擦除动画
- (void)wiped {
    self.imageView.image = [UIImage animatedImageNamed:@"LPBadgeBomb" duration:.25];
    self.imageView.hidden = NO;
    self.valueLabel.text = nil;
    self.valueLabel.hidden = YES;
    self.userInteractionEnabled = NO;
    
    //重置
    [self performSelector:@selector(reset) withObject:nil afterDelay:.25f];
    
    //回调处理
    if (self.wipeHandler) {
        self.wipeHandler();
    }
}

- (void)reset {
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.valueLabel.text = nil;
    self.valueLabel.hidden = YES;
}




//MARK: 拖拽动画

//绘制拖拽动画帧图像
void LPLayerDrawRubber(CALayer *layer, CGPoint p) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = _elasticLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, _badgeLabel.backgroundColor.CGColor);
    CGContextTranslateCTM(ctx, size.width/2.l, size.height/2.l);//将坐标系移至画布中心
    
    
    //小圆弧半径
    CGFloat r = BadgeR - (BadgeR/2.5l) * (Distance(CGPointZero, p)/ElsticMaxR) - 2;
    //角度，逆时针绘制
    double angle = Angle(CGPointZero, p);
    double fixAngle = M_PI_2 * 0.7l;
    double angle1 = angle + fixAngle;
    double angle2 = angle - fixAngle;
    //小圆弧与两条曲线交点
    CGPoint a1 = CGPointMake(r*cos(angle1), r*sin(angle1));
    //曲线的另一个端点
    CGFloat x = BadgeR * sin(angle);
    CGFloat y = BadgeR * cos(angle);
    CGPoint a2 = CGPointMake(p.x-x, p.y+y);
    CGPoint b2 = CGPointMake(p.x+x, p.y-y);
    //两曲线圆心，即二阶贝塞尔曲线控制点
    CGPoint ac = CGPointMake(p.x/2.l, p.y/2.l);
    CGPoint bc = CGPointMake(p.x/2.l, p.y/2.l);
    //绘制曲线
    CGContextMoveToPoint(ctx, a1.x, a1.y);
    CGContextAddArc(ctx, 0, 0, r, angle1, angle2, NO);
    CGContextAddQuadCurveToPoint(ctx, bc.x, bc.y, b2.x, b2.y);
    CGContextAddLineToPoint(ctx, a2.x, a2.y);
    CGContextAddQuadCurveToPoint(ctx, ac.x, ac.y, a1.x, a1.y);
    
    
    CGContextDrawPath(ctx, kCGPathEOFill);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ctx);
    UIGraphicsEndImageContext();
    _elasticLayer.contents = (__bridge id _Nullable)(img.CGImage);
}







#pragma mark - ------------------------ 外观风格配置 --------------------------
- (void)setStyle:(LPBadgeStyle)style {
    if (style == _style) { return; }
    _style = style;
    [self changeToStyle:style];
}

- (void)changeToStyle:(LPBadgeStyle)style {
    switch (style) {
        case LPBadgeStyleValue: {
            self.valueLabel.text = _value;
            self.imageView.image = nil;
            self.valueLabel.hidden = !(_value&&_value.length);
            self.imageView.hidden = YES;
            self.userInteractionEnabled = _value&&_value.length;
        }
            break;
        case LPBadgeStyleDot: {
            self.valueLabel.text = nil;
            self.imageView.image = nil;
            self.valueLabel.hidden = NO;
            self.imageView.hidden = YES;
            self.userInteractionEnabled = NO;
        }
            break;
        case LPBadgeStyleImage: {
            self.valueLabel.text = nil;
            self.imageView.image = _image;
            self.valueLabel.hidden = YES;
            self.imageView.hidden = NO;
            self.userInteractionEnabled = _image;
        }
            break;
        default:
            break;
    }
    [self layoutSubviews];
}



- (void)setValue:(NSString *)value {
    _value = [value copy];
    if (_style == LPBadgeStyleValue) {
        [self changeToStyle:LPBadgeStyleValue];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = [tintColor copy];
    self.valueLabel.backgroundColor = tintColor?:[UIColor redColor];
}

- (void)setWide:(CGFloat)wide {
    _wide = wide;
    [self layoutSubviews];
}



- (void)setImage:(UIImage *)image {
    _image = [image copy];
    if (_style == LPBadgeStyleImage) {
        [self changeToStyle:LPBadgeStyleImage];
    }
}

@end