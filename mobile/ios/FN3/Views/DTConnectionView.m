//
//  DTConnectionView.m
//  FN3
//
//  Created by David Jablonski on 3/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTConnectionView.h"
#include <math.h>

@implementation DTConnectionView

@synthesize commStatus, accessoryColor;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.accessoryColor = [UIColor whiteColor];
}

- (id)copyWithZone:(NSZone *)zone
{
    DTConnectionView *copy = [[DTConnectionView alloc] init];
    [copy awakeFromNib];
    copy.commStatus = self.commStatus;
    copy.accessoryColor = self.accessoryColor;
    return copy;
}

- (void)setCommStatus:(DTCommmStatus)_commStatus
{
    commStatus = _commStatus;
    [self setNeedsDisplay];
}

- (void)setAccessoryColor:(UIColor *)_accessoryColor
{
    accessoryColor = _accessoryColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), rect.size.width / 107.0, rect.size.height / 107.0);
    
    UIColor *color;
    if (DTCommStatusGreen == self.commStatus) {
        color = [UIColor colorWithRed: 0.48 green: 0.73 blue: 0.19 alpha: 1];
        
        //// Checkmark Drawing
        UIBezierPath* checkmarkPath = [UIBezierPath bezierPath];
        [checkmarkPath moveToPoint: CGPointMake(76, 97)];
        [checkmarkPath addLineToPoint: CGPointMake(102.12, 71.35)];
        [checkmarkPath addLineToPoint: CGPointMake(95.17, 64.26)];
        [checkmarkPath addLineToPoint: CGPointMake(76.65, 82.78)];
        [checkmarkPath addLineToPoint: CGPointMake(70, 76)];
        [checkmarkPath addLineToPoint: CGPointMake(63, 83)];
        [checkmarkPath addLineToPoint: CGPointMake(76, 97)];
        [checkmarkPath closePath];
        [self.accessoryColor setFill];
        [checkmarkPath fill];
    } else if (DTCommStatusRed == self.commStatus) {
        color =  [UIColor colorWithRed: 0.69 green: 0.08 blue: 0.13 alpha: 1];
        
        //// X Left Drawing
        UIBezierPath* xLeftPath = [UIBezierPath bezierPath];
        [xLeftPath moveToPoint: CGPointMake(68, 73)];
        [xLeftPath addLineToPoint: CGPointMake(95.17, 100.74)];
        [xLeftPath addLineToPoint: CGPointMake(102.24, 93.67)];
        [xLeftPath addLineToPoint: CGPointMake(88.72, 80.15)];
        [xLeftPath addLineToPoint: CGPointMake(75, 66)];
        [xLeftPath addLineToPoint: CGPointMake(68, 73)];
        [xLeftPath closePath];
        [self.accessoryColor setFill];
        [xLeftPath fill];
        
        //// X Right Drawing
        UIBezierPath* xRightPath = [UIBezierPath bezierPath];
        [xRightPath moveToPoint: CGPointMake(95.99, 65.75)];
        [xRightPath addLineToPoint: CGPointMake(68.25, 92.92)];
        [xRightPath addLineToPoint: CGPointMake(75.32, 99.99)];
        [xRightPath addLineToPoint: CGPointMake(88.83, 86.47)];
        [xRightPath addLineToPoint: CGPointMake(102.99, 72.75)];
        [xRightPath addLineToPoint: CGPointMake(95.99, 65.75)];
        [xRightPath closePath];
        [self.accessoryColor setFill];
        [xRightPath fill];
    } else if (DTCommStatusYellow == self.commStatus) {
        color = [UIColor colorWithRed: 0.48 green: 0.73 blue: 0.19 alpha: 1];
        
        //// Exclamation Top Drawing
        UIBezierPath* exclamationTopPath = [UIBezierPath bezierPath];
        [exclamationTopPath moveToPoint: CGPointMake(82, 81)];
        [exclamationTopPath addLineToPoint: CGPointMake(92, 81)];
        [exclamationTopPath addLineToPoint: CGPointMake(92, 55)];
        [exclamationTopPath addLineToPoint: CGPointMake(82, 55)];
        [exclamationTopPath addLineToPoint: CGPointMake(82, 81)];
        [exclamationTopPath closePath];
        //[[UIColor whiteColor] setFill];
        [self.accessoryColor setFill];
        [exclamationTopPath fill];
        
        //// Exclamation Bottom Drawing
        UIBezierPath* exclamationBottomPath = [UIBezierPath bezierPathWithRect: CGRectMake(82, 86, 10, 10)];
        //[[UIColor whiteColor] setFill];
        [self.accessoryColor setFill];
        [exclamationBottomPath fill];
        
    } else {
        color =  [UIColor colorWithRed: 0.53 green: 0.53 blue: 0.53 alpha: 1];
        
        //// Negative Mark Drawing
        UIBezierPath* negativeMarkPath = [UIBezierPath bezierPathWithRect: CGRectMake(65, 79, 36, 10)];
        [self.accessoryColor setFill];
        [negativeMarkPath fill];
    }
    
    
    //// Main Top Drawing
    UIBezierPath* mainTopPath = [UIBezierPath bezierPath];
    [mainTopPath moveToPoint: CGPointMake(13.5, 36)];
    [mainTopPath addCurveToPoint: CGPointMake(51.5, 20) controlPoint1: CGPointMake(13.5, 36) controlPoint2: CGPointMake(30.21, 19.89)];
    [mainTopPath addCurveToPoint: CGPointMake(92.5, 36) controlPoint1: CGPointMake(77.54, 20.13) controlPoint2: CGPointMake(92.5, 36)];
    [mainTopPath addCurveToPoint: CGPointMake(102.03, 26.88) controlPoint1: CGPointMake(92.5, 36) controlPoint2: CGPointMake(98.07, 30.31)];
    [mainTopPath addCurveToPoint: CGPointMake(52.5, 6.5) controlPoint1: CGPointMake(91.61, 16.23) controlPoint2: CGPointMake(76.5, 6.36)];
    [mainTopPath addCurveToPoint: CGPointMake(4.64, 26.88) controlPoint1: CGPointMake(35.07, 6.56) controlPoint2: CGPointMake(19.42, 11.52)];
    [mainTopPath addCurveToPoint: CGPointMake(13.5, 36) controlPoint1: CGPointMake(5.63, 27.7) controlPoint2: CGPointMake(13.5, 36)];
    [mainTopPath closePath];
    [color setFill];
    [mainTopPath fill];
    
    //// Main Middle Drawing
    UIBezierPath* mainMiddlePath = [UIBezierPath bezierPath];
    [mainMiddlePath moveToPoint: CGPointMake(53, 44.5)];
    [mainMiddlePath addCurveToPoint: CGPointMake(74.27, 53.79) controlPoint1: CGPointMake(66.69, 44.49) controlPoint2: CGPointMake(74.27, 53.79)];
    [mainMiddlePath addCurveToPoint: CGPointMake(83.2, 44.5) controlPoint1: CGPointMake(74.27, 53.79) controlPoint2: CGPointMake(83.49, 44.57)];
    [mainMiddlePath addCurveToPoint: CGPointMake(53, 31) controlPoint1: CGPointMake(75.23, 35.33) controlPoint2: CGPointMake(64.55, 31.19)];
    [mainMiddlePath addCurveToPoint: CGPointMake(23, 44.5) controlPoint1: CGPointMake(40.93, 30.8) controlPoint2: CGPointMake(31.28, 36.22)];
    [mainMiddlePath addCurveToPoint: CGPointMake(31.54, 53.79) controlPoint1: CGPointMake(24.41, 45.46) controlPoint2: CGPointMake(31.54, 53.79)];
    [mainMiddlePath addCurveToPoint: CGPointMake(53, 44.5) controlPoint1: CGPointMake(31.54, 53.79) controlPoint2: CGPointMake(39.31, 44.51)];
    [mainMiddlePath closePath];
    [color setFill];
    [mainMiddlePath fill];
    
    //// Main Bottom Drawing
    UIBezierPath* mainBottomPath = [UIBezierPath bezierPath];
    [mainBottomPath moveToPoint: CGPointMake(53.5, 74.5)];
    [mainBottomPath addLineToPoint: CGPointMake(65.5, 61.5)];
    [mainBottomPath addCurveToPoint: CGPointMake(53.5, 57) controlPoint1: CGPointMake(65.5, 61.5) controlPoint2: CGPointMake(60.82, 57)];
    [mainBottomPath addCurveToPoint: CGPointMake(41, 61.5) controlPoint1: CGPointMake(46.18, 57) controlPoint2: CGPointMake(41, 61.5)];
    [mainBottomPath addLineToPoint: CGPointMake(53.5, 74.5)];
    [mainBottomPath closePath];
    [color setFill];
    [mainBottomPath fill];
}

@end
