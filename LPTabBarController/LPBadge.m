//
//  LPBadge.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/28.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "LPBadge.h"

typedef NS_ENUM(NSInteger, LPBState) {
    ///静止状态（初始默认状态）
    LPBStateNormal,
    ///拉伸状态（橡皮筋拉伸，徽标随触摸点移动）
    LPBStateTensile,
    ///拉伸断裂状态
    LPBStateBreak,
    ///自动回弹或擦除状态
    LPBStateBackOrWiped,
};


@interface LPBadge ()
{
    CGPoint touchBeganPoint;//触摸开始的点
    LPBState state;//状态
}
@property (weak, nonatomic, readonly) UIWindow *window;
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CALayer *animationLayer;
@end


@implementation LPBadge

///默认半径
const CGFloat DefualtR = 9;
///最小边长
const CGFloat MinWide = 30;
///小红点直径
const CGFloat RedDotWide = 8;
///可回弹的最大半径
const CGFloat ElsticMaxR = 60;

#pragma mark - ------------------------ 初始化、重写 --------------------------
- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAfterWiped) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetAfterBacked) object:nil];
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
    __weak UIWindow *window = [[UIApplication sharedApplication].delegate window];
    _window = window;
    //标签
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.clipsToBounds = YES;
    self.valueLabel.font = [UIFont systemFontOfSize:11];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.hidden = YES;
    [self addSubview:self.valueLabel];
    
    //图片容器
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.clipsToBounds = NO;
    self.imageView.hidden = YES;
    [self addSubview:self.imageView];
    
    //动画图层
    self.animationLayer = [CALayer layer];
    self.animationLayer.fillMode = kCAFillRuleNonZero;
    self.animationLayer.masksToBounds = NO;
    
    //其它
    self.clipsToBounds = NO;
    self.tintColor = [UIColor redColor];
    self.wide = DefualtR*2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //动画图层
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGPoint p = [self convertPoint:Center(self.bounds) toView:self.window];
    self.animationLayer.frame = CGRectMake(p.x-ElsticMaxR, p.y-ElsticMaxR, ElsticMaxR*2, ElsticMaxR*2);
    [CATransaction commit]; 
    
    if (self.valueLabel.superview != self) { return; }
    if (self.imageView.superview != self) { return; }
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
    CGPoint centerP = Center(self.bounds);
    
    //valueLabel尺寸位置
    self.valueLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    self.valueLabel.layer.cornerRadius = size.height/2.0f;
    self.valueLabel.center = centerP;
    
    //imageView尺寸位置
    self.imageView.center = centerP;
}


//MARK: 外部方法 擦除
- (void)wipedWithAnimated:(BOOL)animated {
    if (animated) {
        [self startWipedAnimating];
    }else {
        [self resetAfterWiped];
        //回调处理
        if (self.delegate && [self.delegate respondsToSelector:@selector(badge:didWipedWithAnimated:)]) {
            [self.delegate badge:self didWipedWithAnimated:NO];
        }
    }
}



//MARK: 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeTouches) { return; }
    CGPoint p = [self locationOfTouches:touches];//以self自身中心为原点的坐标
    touchBeganPoint = p;
    
    //进入默认状态
    state = LPBStateNormal;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeTouches) { return; }
    CGPoint p = [self locationOfTouches:touches];//以self自身中心为原点的坐标
    
    //进入拉伸状态
    if (state == LPBStateNormal && !CGPointEqualToPoint(touchBeganPoint, p)) {
        [self.window.layer addSublayer:self.animationLayer];
        [self.imageView removeFromSuperview];
        [self.valueLabel removeFromSuperview];
        [self.window addSubview:self.imageView];
        [self.window addSubview:self.valueLabel];
        state = LPBStateTensile;
    }
    
    //进入断裂状态
    if (state == LPBStateTensile && Distance(CGPointZero, p) > ElsticMaxR) {
        [self.animationLayer removeFromSuperlayer];
        self.animationLayer.contents = nil;
        state = LPBStateBreak;
    }
    
    //开始拖拽
    if (state == LPBStateTensile) {
        [self dragToPoint:p];
        [self drawFrameWith:p];
    }else if (state == LPBStateBreak) {
        [self dragToPoint:p];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeTouches) { return; }
    CGPoint p = [self locationOfTouches:touches];//以self自身中心为原点的坐标
    
    if (state==LPBStateTensile) {
        [self startBackAnimatingFrom:p];
    }else if (state==LPBStateBreak && Distance(CGPointZero, p)<ElsticMaxR) {
        [self resetAfterBacked];
    }else {
        [self startWipedAnimating];
    }
    
    //进入自动回弹或擦除状态
    state = LPBStateBackOrWiped;
    touchBeganPoint = CGPointMake(-1, -1);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeTouches) { return; }
    
    //重置状态默认状态
    if (state != LPBStateNormal) {
        [self.animationLayer removeFromSuperlayer];
        self.animationLayer.contents = nil;
        [self resetAfterBacked];
    }
    
    self.userInteractionEnabled = YES;
    state = LPBStateNormal;
    touchBeganPoint = CGPointMake(-1, -1);
}



#pragma mark - ------------------------ 动画 --------------------------
//MARK: 擦除动画
- (void)startWipedAnimating {
    self.imageView.image = [UIImage animatedImageNamed:@"LPBadgeBomb" duration:.25];
    self.imageView.hidden = NO;
    self.valueLabel.text = nil;
    self.valueLabel.hidden = YES;
    [self.animationLayer removeFromSuperlayer];
    self.animationLayer.contents = nil;
    self.userInteractionEnabled = NO;
    
    //重置
    [self performSelector:@selector(resetAfterWiped) withObject:nil afterDelay:.25f];
    
    //回调处理
    if (self.delegate && [self.delegate respondsToSelector:@selector(badge:didWipedWithAnimated:)]) {
        [self.delegate badge:self didWipedWithAnimated:YES];
    }
}

//擦除重置
- (void)resetAfterWiped {
    [self.animationLayer removeFromSuperlayer];
    self.animationLayer.contents = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    [self.imageView removeFromSuperview];
    [self addSubview:self.imageView];
    
    self.valueLabel.text = nil;
    self.valueLabel.hidden = YES;
    [self.valueLabel removeFromSuperview];
    [self addSubview:self.valueLabel];
    
    [self layoutSubviews];
}




//MARK: 拖拽动画
- (void)dragToPoint:(CGPoint)p {
    CGPoint center = [self convertPoint:Center(self.bounds) toView:self.window];
    CGPoint pInWindow = CGPointMake(center.x+p.x, center.y+p.y);
    self.imageView.center = pInWindow;
    self.valueLabel.center = pInWindow;
}

//绘制中间弹力部分
- (void)drawFrameWith:(CGPoint)point {
    CGImageRef img = LPBadgeCreatRubber(self.animationLayer.bounds.size, point, self.tintColor.CGColor);
    self.animationLayer.contents = (__bridge id _Nullable)img;
}




//MARK: 回弹动画
- (void)startBackAnimatingFrom:(CGPoint)p {
    self.userInteractionEnabled = NO;
    [self.animationLayer removeFromSuperlayer];
    self.animationLayer.contents = nil;
    
    //动画
    [self backFrom:p count:0];
}

//回弹动画
- (void)backFrom:(CGPoint)p count:(NSInteger)count {
    self.userInteractionEnabled = NO;
    CGFloat m = 0.3; //回弹力消弱系数
    
    //新的目标地址
    p.x = - p.x * m;
    p.y = - p.y * m;
    CGPoint center = [self convertPoint:Center(self.bounds) toView:self.window];
    CGPoint pInWindow = CGPointMake(center.x+p.x, center.y+p.y);
    
    //动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.imageView.center = pInWindow;
        weakSelf.valueLabel.center = pInWindow;
    } completion:^(BOOL finished) {
        if (finished && count < 4) {
            [weakSelf backFrom:p count:count+1];//循环调用，继续执行动画
        }else{
            [self resetAfterBacked];
        }
    }];
}


//重置
- (void)resetAfterBacked {
    self.userInteractionEnabled = YES;
    
    [self.imageView removeFromSuperview];
    [self addSubview:self.imageView];
    
    [self.valueLabel removeFromSuperview];
    [self addSubview:self.valueLabel];
    
    [self layoutSubviews];
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
            self.userInteractionEnabled = _image!=nil;
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
    _tintColor = [tintColor copy]?:[UIColor redColor];
    self.valueLabel.backgroundColor = _tintColor;
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




#pragma mark - ------------------------ 辅助方法 --------------------------
//计算两点间直线与水平线的夹角,逆时针
double Angle(CGPoint p1, CGPoint p2) {
    CGFloat angle = atan((p2.y-p1.y)/(p2.x-p1.x));
    if (p2.x < p1.x) {
        angle += M_PI;
    }else if (p2.x == p1.x) {
        if (p2.y > p1.y) angle = M_PI_2;
        else angle = M_PI_2 + M_PI;
    }
    return angle;
}

//计算两点间距离
double Distance(CGPoint p1, CGPoint p2) {
    return sqrt(pow(p2.x-p1.x, 2) + pow(p2.y-p1.y, 2));
}

//Rect相对于自身的中心位置
CGPoint Center(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

//相对位置
- (CGPoint)locationOfTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint l = [touch locationInView:self];
    return CGPointMake(l.x - CGRectGetMidX(self.bounds), l.y - CGRectGetMidX(self.bounds));
}


//绘制拖拽动画帧图像
CGImageRef LPBadgeCreatRubber(CGSize size, CGPoint p, CGColorRef color) {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextTranslateCTM(ctx, size.width/2.l, size.height/2.l);//将坐标系移至画布中心
    //小圆弧半径
    CGFloat r = DefualtR - (DefualtR/2.5l) * (Distance(CGPointZero, p)/ElsticMaxR) - 2;
    //角度，逆时针绘制
    double angle = Angle(CGPointZero, p);
    double fixAngle = M_PI_2 * 0.7l;
    double angle1 = angle + fixAngle;
    double angle2 = angle - fixAngle;
    //小圆弧与两条曲线交点
    CGPoint a1 = CGPointMake(r*cos(angle1), r*sin(angle1));
    //曲线的另一个端点
    CGFloat x = DefualtR * sin(angle);
    CGFloat y = DefualtR * cos(angle);
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
    return img.CGImage;
}
@end
