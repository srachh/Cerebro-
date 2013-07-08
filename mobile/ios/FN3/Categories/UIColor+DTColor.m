//
//  UIColor+DTColor.m
//  FN3
//
//  Created by David Jablonski on 2/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "UIColor+DTColor.h"

@implementation UIColor (DTColor)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{  
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    cString = [cString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (cString.length == 6) {
        // Separate into r, g, b substrings  
        NSRange range = {.location = 0, .length = 2};
        NSString *rString = [cString substringWithRange:range];  
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];  
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];  
        
        // Scan values  
        unsigned int r, g, b;  
        [[NSScanner scannerWithString:rString] scanHexInt:&r];  
        [[NSScanner scannerWithString:gString] scanHexInt:&g];  
        [[NSScanner scannerWithString:bString] scanHexInt:&b];  
        
        return [UIColor colorWithRed:((float) r / 255.0f)  
                               green:((float) g / 255.0f)  
                                blue:((float) b / 255.0f)  
                               alpha:1.0f];  
    } else {
        return [UIColor blackColor];
    }
}

- (UIColor *)darkerColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = MAX(components[0] - (components[0] * 0.3), 0);
    CGFloat g = MAX(components[1] - (components[1] * 0.3), 0);
    CGFloat b = MAX(components[2] - (components[2] * 0.3), 0);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:components[3]];
}

- (UIColor *)lighterColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = MIN(components[0] + (components[0] * 0.3), 1);
    CGFloat g = MIN(components[1] + (components[1] * 0.3), 1);
    CGFloat b = MIN(components[2] + (components[2] * 0.3), 1);

    return [UIColor colorWithRed:r green:g blue:b alpha:components[3]];
}

+ (UIColor *)barButtonItemTintColor
{
    static dispatch_once_t pred = 0;
    __strong static id _barButtonItemTintColor = nil;
    dispatch_once(&pred, ^{
        _barButtonItemTintColor = [UIColor colorWithRed:.65 green:.65 blue:.65 alpha:1];
//        _barButtonItemTintColor = [UIColor colorFromHexString:@"#8e8e8e"];
    });
    return _barButtonItemTintColor;
}

+ (UIColor *)barButtonSaveItemTintColor
{
    static dispatch_once_t pred = 0;
    __strong static id _barButtonSaveItemTintColor = nil;
    dispatch_once(&pred, ^{
        _barButtonSaveItemTintColor = [UIColor colorWithRed:.24 green:.62 blue:.94 alpha:1];
    });
    return _barButtonSaveItemTintColor;
}

+ (UIColor *)rgbBlackColor
{
    static UIColor *rgbBlackColor;
    if (!rgbBlackColor) {
        rgbBlackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    return rgbBlackColor;
}

+ (UIColor *)rgbBlackGradientColor
{
    static UIColor *rgbBlackGradientColor;
    if (!rgbBlackGradientColor) {
        rgbBlackGradientColor = [UIColor colorWithRed:.16 green:.16 blue:.16 alpha:1];
    }
    return rgbBlackGradientColor;
}

+ (UIColor *)rgbBlackHeaderGradientColor
{
    static UIColor *rgbBlackHeaderGradientColor;
    if (!rgbBlackHeaderGradientColor) {
        rgbBlackHeaderGradientColor = [UIColor colorWithRed:.10 green:.10 blue:.10 alpha:1];
    }
    return rgbBlackHeaderGradientColor;
}

- (UIImage *)imageOfSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    [self setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
