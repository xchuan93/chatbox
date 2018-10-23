//
//  UIColor+RGB.m
//  StemCells
//
//  Created by Apple on 2018/9/27.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)

+ (UIColor *)colorWithRGB:(CGFloat)r g:(CGFloat)g b:(CGFloat)b alpha:(CGFloat)alpha{
    UIColor *color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:alpha];
    return color;
}

@end
