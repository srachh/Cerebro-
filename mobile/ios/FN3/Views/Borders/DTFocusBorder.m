//
//  DTFocusBorder.m
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTFocusBorder.h"

@implementation DTFocusBorder

- (id<DTBorder>)borderWithAlpha:(CGFloat)alpha
{
    return self;
}

- (void)drawInContext:(CGContextRef)context path:(UIBezierPath *)path rect:(CGRect)rect
{
    //// Color Declarations
    UIColor* selectedBlue = [UIColor colorWithRed: 0.08 green: 0.61 blue: 0.95 alpha: 1];
    
    //// Shadow Declarations
    CGColorRef shadow = selectedBlue.CGColor;
    CGSize shadowOffset = CGSizeMake(0, -0);
    CGFloat shadowBlurRadius = 10;
    
    
    //// Inward Shadow Layer 2 Drawing
    UIBezierPath* inwardShadowLayer2Path = path;
    [[UIColor clearColor] setFill];
    [inwardShadowLayer2Path fill];
    
    ////// Inward Shadow Layer 2 Inner Shadow
    CGRect inwardShadowLayer2BorderRect = CGRectInset([inwardShadowLayer2Path bounds], -shadowBlurRadius, -shadowBlurRadius);
    inwardShadowLayer2BorderRect = CGRectOffset(inwardShadowLayer2BorderRect, -shadowOffset.width, -shadowOffset.height);
    inwardShadowLayer2BorderRect = CGRectInset(CGRectUnion(inwardShadowLayer2BorderRect, [inwardShadowLayer2Path bounds]), -1, -1);
    
    UIBezierPath* inwardShadowLayer2NegativePath = [UIBezierPath bezierPathWithRect: inwardShadowLayer2BorderRect];
    [inwardShadowLayer2NegativePath appendPath: inwardShadowLayer2Path];
    inwardShadowLayer2NegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(inwardShadowLayer2BorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow);
        
        [inwardShadowLayer2Path addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(inwardShadowLayer2BorderRect.size.width), 0);
        [inwardShadowLayer2NegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [inwardShadowLayer2NegativePath fill];
    }
    CGContextRestoreGState(context);
    
    
    //// Inward Shadow Layer 1 Drawing
    UIBezierPath* inwardShadowLayer1Path = path;
    [[UIColor clearColor] setFill];
    [inwardShadowLayer1Path fill];
    
    ////// Inward Shadow Layer 1 Inner Shadow
    CGRect inwardShadowLayer1BorderRect = CGRectInset([inwardShadowLayer1Path bounds], -shadowBlurRadius, -shadowBlurRadius);
    inwardShadowLayer1BorderRect = CGRectOffset(inwardShadowLayer1BorderRect, -shadowOffset.width, -shadowOffset.height);
    inwardShadowLayer1BorderRect = CGRectInset(CGRectUnion(inwardShadowLayer1BorderRect, [inwardShadowLayer1Path bounds]), -1, -1);
    
    UIBezierPath* inwardShadowLayer1NegativePath = [UIBezierPath bezierPathWithRect: inwardShadowLayer1BorderRect];
    [inwardShadowLayer1NegativePath appendPath: inwardShadowLayer1Path];
    inwardShadowLayer1NegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(inwardShadowLayer1BorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow);
        
        [inwardShadowLayer1Path addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(inwardShadowLayer1BorderRect.size.width), 0);
        [inwardShadowLayer1NegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [inwardShadowLayer1NegativePath fill];
    }
    CGContextRestoreGState(context);
}

@end
