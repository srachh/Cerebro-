//
//  DTSolidShader.m
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSolidShader.h"

@implementation DTSolidShader
@synthesize color;

- (id)init{
    return self = [super init];
}

- (id)initWithColor:(UIColor *)aColor
{
    if (self = [super init]) {
        color = aColor;
    }
    return self;
}

- (void)dealloc
{
    color = nil;
}

- (id<DTShader>)shaderWithAlpha:(CGFloat)alpha
{
    return [[DTSolidShader alloc] initWithColor:[self.color colorWithAlphaComponent:alpha]];
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextBeginPath(context);
    CGContextAddRect(context, rect);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

@end
