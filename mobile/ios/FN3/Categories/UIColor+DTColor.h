//
//  UIColor+DTColor.h
//  FN3
//
//  Created by David Jablonski on 2/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DTColor)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (UIColor *)darkerColor;
- (UIColor *)lighterColor;

+ (UIColor *)barButtonItemTintColor;
+ (UIColor *)barButtonSaveItemTintColor;

+ (UIColor *)rgbBlackColor;
+ (UIColor *)rgbBlackGradientColor;
+ (UIColor *)rgbBlackHeaderGradientColor;

- (UIImage *)imageOfSize:(CGSize)size;

@end
