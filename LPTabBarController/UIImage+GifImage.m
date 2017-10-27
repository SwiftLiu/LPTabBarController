//
//  UIImage+GifImage.m
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/25.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import "UIImage+GifImage.h"

@implementation UIImage (GifImage)
//GIF第一帧
+ (UIImage *)firstFrameOfGifImageData:(NSData *)data {
    if (!data) { return nil; }
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t frameCount = CGImageSourceGetCount(gifSource);//帧数
    UIImage *firstFrame = nil;
    if (frameCount <= 1) {
        firstFrame = [[UIImage alloc] initWithData:data];
    }else {
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, 0, NULL);
        firstFrame = [UIImage imageWithCGImage:frame scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        CGImageRelease(frame);
    }
    return firstFrame;
}

//生成GIF图
+ (UIImage *)gifImageWithData:(NSData *)data {
    if (!data) { return nil; }
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t frameCount = CGImageSourceGetCount(gifSource);//帧数
    UIImage *animatedImage = nil;
    
    if (frameCount <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }else {
        NSMutableArray *frames = [NSMutableArray array];
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < frameCount; ++i) {
            //获取每帧图像
            CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            UIImage *frameImg = [UIImage imageWithCGImage:frame scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [frames addObject:frameImg];
            CGImageRelease(frame);
            
            //循环播放一次动画时间
            NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
            NSDictionary *gifPproperties = [properties valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
            NSTimeInterval addTimes = [[gifPproperties valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
            duration += addTimes;
        }
        CFRelease(gifSource);
        duration = duration?:(0.1f*frameCount);//每一帧时间间隔是平均的
        animatedImage = [UIImage animatedImageWithImages:frames duration:duration];
    }
    
    return animatedImage;
}
@end
