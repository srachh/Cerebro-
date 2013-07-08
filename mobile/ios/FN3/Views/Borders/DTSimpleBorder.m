//
//  DTSimpleBorder.m
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSimpleBorder.h"

@implementation DTSimpleBorder
@synthesize outerColor, innerColor;

- (id)init
{
    return self = [super init];
}

- (id)initWithOuterColor:(UIColor *)anOuterColor innerColor:(UIColor *)anInnerColor
{
    if (self = [super init]) {
        outerColor = anOuterColor;
        innerColor = anInnerColor;
    }
    return self;
}

- (void)dealloc
{
    outerColor = innerColor = nil;
}

- (id<DTBorder>)borderWithAlpha:(CGFloat)alpha
{
    return [[DTSimpleBorder alloc] initWithOuterColor:[self.outerColor colorWithAlphaComponent:alpha] 
                                           innerColor:[self.innerColor colorWithAlphaComponent:alpha]];
}

- (void)drawInContext:(CGContextRef)context path:(UIBezierPath *)path rect:(CGRect)rect
{
    if (innerColor && outerColor) {
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, self.outerColor.CGColor);
        CGContextDrawPath(context, kCGPathStroke);
        
        CGContextMoveToPoint(context, rect.origin.x + 2, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x + 2, rect.origin.y + 2);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + 2);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, self.innerColor.CGColor);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

@end
