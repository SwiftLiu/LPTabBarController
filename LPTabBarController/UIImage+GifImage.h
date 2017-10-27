//
//  UIImage+GifImage.h
//  LartTabBarController
//
//  Created by iOSLiu on 2017/10/25.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GifImage)
/** GIF第一帧 */
+ (UIImage *)firstFrameOfGifImageData:(NSData *)data;
/** 生成GIF图 */
+ (UIImage *)gifImageWithData:(NSData *)data;
@end
