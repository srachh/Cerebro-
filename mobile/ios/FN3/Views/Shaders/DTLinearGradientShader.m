//
//  DTLinearGradientShader.m
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTLinearGradientShader.h"

@implementation DTLinearGradientShader
@synthesize orientation;

- (id)init
{
    if (self = [super init]) {
        colors = [[NSMutableArray alloc] init];
        locations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor
{
    if (self = [self init]) {
        [self addColor:fromColor atLocation:0.0];
        [self addColor:toColor atLocation:1.0];
    }
    return self;
}

- (id)initWithColors:(NSArray *)myColors atLocations:(NSArray *)myLocations
{
    if (myColors.count != myLocations.count) {
        [[NSException exceptionWithName:@"color and location count mismatch" 
                                 reason:@"the number of colors does not equal the number of locations" 
                               userInfo:nil] raise];
    }
    
    if (self = [self init]) {
        for (int i = 0; i < myColors.count; i++) {
            [colors addObject:[myColors objectAtIndex:i]];
            [locations addObject:[myLocations objectAtIndex:i]];
        }
    }
    return self;
}

- (id<DTShader>)shaderWithAlpha:(CGFloat)alpha
{
    DTLinearGradientShader *shader = [[DTLinearGradientShader alloc] init];
    for (int i = 0; i < colors.count; i++) {
        [shader addColor:[[colors objectAtIndex:i] colorWithAlphaComponent:alpha] 
              atLocation:[[locations objectAtIndex:i] floatValue]];
    }
    return shader;
}

- (void)addColor:(UIColor *)color atLocation:(CGFloat)location;
{
    [colors addObject:color];
    [locations addObject:[NSNumber numberWithFloat:location]];
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect;
{
    CGFloat cgLocations[locations.count];
    for (int i = 0; i < locations.count; i++) {
        NSNumber *loc = [locations objectAtIndex:i];
        cgLocations[i] = [loc floatValue];
    }
    
    CGFloat cgComponents[colors.count * 4];
    for (int i = 0; i < colors.count; i++) {
        UIColor *color = [colors objectAtIndex:i];
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        for (int j = 0; j < 4; j++) {
            cgComponents[(i * 4) + j] = components[j];
        }
    }
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, 
                                                                   cgComponents,
                                                                   cgLocations, 
                                                                   locations.count);
    
    if (orientation == DTLinearGradientOrientationVertical) {
        CGContextDrawLinearGradient(context, 
                                    myGradient, 
                                    CGPointMake(rect.origin.x, rect.origin.y), 
                                    CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 
                                    kCGGradientDrawsAfterEndLocation);
    } else {
        CGContextDrawLinearGradient(context, 
                                    myGradient, 
                                    CGPointMake(rect.origin.x, rect.origin.y), 
                                    CGPointMake(rect.origin.x + rect.size.width, rect.origin.y), 
                                    kCGGradientDrawsAfterEndLocation);
    }
    
    CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
}

@end
