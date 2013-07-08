//
//  DTPumpStationView.m
//  FieldNET
//
//  Created by Loren Davelaar on 9/19/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPumpStationView.h"
#import "DTPumpStation.h"
#import "UIColor+DTColor.h"
#import "DTPumpStation.h"

@implementation DTPumpStationView

@synthesize color, shadowColor, pumpState;
@synthesize detailLevel;

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.color = [UIColor colorWithRed: 0.08 green: 0.49 blue: 0.97 alpha: 1];
    self.shadowColor = [UIColor colorWithRed: 0.2 green: 0.19 blue: 0.19 alpha: 1]; 
    self.pumpState = DTPumpStateNormal;
    self.backgroundColor = [UIColor clearColor];
}

- (id)copyWithZone:(NSZone *)zone
{
    DTPumpStationView *copy = [[DTPumpStationView alloc] initWithFrame:self.frame];
    copy.color = self.color;
    copy.shadowColor = self.shadowColor;
    copy.pumpState = self.pumpState;
    copy.detailLevel = self.detailLevel;
    return copy;
}

- (void)configureFromEquipment:(DTEquipment *)equipment
{
    DTPumpStation *pump = (DTPumpStation *)equipment;
    
    self.color = [UIColor colorFromHexString:pump.color];
    self.pumpState = pump.state;
    
    [self setNeedsDisplay];
}

- (void)configureFromPump:(DTPump  *)pump
{
    self.color = [UIColor colorFromHexString:pump.color];
    self.pumpState = pump.state;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextSaveGState(UIGraphicsGetCurrentContext());
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), rect.size.width / 92, rect.size.height / 92);
    
    //// Color Declarations
    //UIColor* rectangleBlueColor = [UIColor colorWithRed: 0.08 green: 0.49 blue: 0.97 alpha: 1];
    CGFloat colorRedValue;
    CGFloat colorGreenValue;
    CGFloat colorBlueValue;
    CGFloat colorAlphaValue;
    
    [self.color getRed:&colorRedValue green:&colorGreenValue blue:&colorBlueValue alpha:&colorAlphaValue];
    
    colorRedValue -= 0.01;
    if (colorRedValue < 0) {
        colorRedValue = 0;
    }
    
    colorGreenValue -= 0.16;
    if (colorGreenValue < 0) {
        colorGreenValue = 0;
    }
    
    colorBlueValue -= 0.35;
    if (colorBlueValue < 0) {
        colorBlueValue = 0;
    }
    //UIColor* mediumBluePumpOutlineColor = [UIColor colorWithRed: 0.07 green: 0.33 blue: 0.62 alpha: 1];
    
    UIColor* mediumBluePumpOutlineColor = [UIColor colorWithRed: colorRedValue green: colorGreenValue blue: colorBlueValue alpha: colorAlphaValue];
    
    //// Rectangle Background Drawing Drawing
    UIBezierPath* rectangleBackgroundDrawingPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(2, 2, 88, 88) cornerRadius: 6];
    //[rectangleBlueColor setFill];
    [self.color setFill];
    [rectangleBackgroundDrawingPath fill];
    
    //// Pump Outline Drawing
    UIBezierPath* pumpOutlineDrawingPath = [UIBezierPath bezierPath];
    [pumpOutlineDrawingPath moveToPoint: CGPointMake(75, 35)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(70, 35)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(70, 33)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(67.63, 33)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(64.85, 61.36) controlPoint1: CGPointMake(72.23, 42.04) controlPoint2: CGPointMake(71.3, 53.17)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(69.5, 64.5) controlPoint1: CGPointMake(66.67, 62.54) controlPoint2: CGPointMake(69.69, 64.5)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(69, 76) controlPoint1: CGPointMake(69.23, 64.5) controlPoint2: CGPointMake(69, 76)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(19.5, 76.5)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(19.5, 64.5)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(23.74, 62.08)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(25.26, 26.26) controlPoint1: CGPointMake(14.94, 51.67) controlPoint2: CGPointMake(15.45, 36.07)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(36, 20) controlPoint1: CGPointMake(25.26, 26.26) controlPoint2: CGPointMake(29.23, 22.03)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(49.06, 19) controlPoint1: CGPointMake(42.77, 17.97) controlPoint2: CGPointMake(46.07, 19)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(49.13, 19)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(70, 19)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(70, 17)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(75, 17)];
    [pumpOutlineDrawingPath addLineToPoint: CGPointMake(75, 35)];
    [pumpOutlineDrawingPath closePath];
    [pumpOutlineDrawingPath moveToPoint: CGPointMake(36.58, 37.58)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(36.58, 52.42) controlPoint1: CGPointMake(32.47, 41.68) controlPoint2: CGPointMake(32.47, 48.32)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(51.42, 52.42) controlPoint1: CGPointMake(40.68, 56.53) controlPoint2: CGPointMake(47.32, 56.53)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(51.42, 37.58) controlPoint1: CGPointMake(55.53, 48.32) controlPoint2: CGPointMake(55.53, 41.68)];
    [pumpOutlineDrawingPath addCurveToPoint: CGPointMake(36.58, 37.58) controlPoint1: CGPointMake(47.32, 33.47) controlPoint2: CGPointMake(40.68, 33.47)];
    [pumpOutlineDrawingPath closePath];
    [[UIColor whiteColor] setFill];
    [pumpOutlineDrawingPath fill];
    
    [mediumBluePumpOutlineColor setStroke];
    pumpOutlineDrawingPath.lineWidth = 6;
    [pumpOutlineDrawingPath stroke];
    
    //// Pump Station Base Drawing
    UIBezierPath* baseDrawingPath = [UIBezierPath bezierPath];
    [baseDrawingPath moveToPoint: CGPointMake(19.5, 64.5)];
    [baseDrawingPath addLineToPoint: CGPointMake(26.5, 60.5)];
    [baseDrawingPath addLineToPoint: CGPointMake(63.5, 60.5)];
    [baseDrawingPath addCurveToPoint: CGPointMake(69.5, 64.5) controlPoint1: CGPointMake(63.5, 60.5) controlPoint2: CGPointMake(69.77, 64.5)];
    [baseDrawingPath addCurveToPoint: CGPointMake(69, 76) controlPoint1: CGPointMake(69.23, 64.5) controlPoint2: CGPointMake(69, 76.19)];
    [baseDrawingPath addCurveToPoint: CGPointMake(19.5, 76.5) controlPoint1: CGPointMake(69, 75.81) controlPoint2: CGPointMake(19.5, 76.5)];
    [baseDrawingPath addLineToPoint: CGPointMake(19.5, 64.5)];
    [baseDrawingPath closePath];
    [[UIColor whiteColor] setFill];
    [baseDrawingPath fill];
    
    //// Circular Tube Drawing Drawing
    UIBezierPath* circularTubeDrawingPath = [UIBezierPath bezierPath];
    [circularTubeDrawingPath moveToPoint: CGPointMake(36.58, 37.9)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(36.58, 52.6) controlPoint1: CGPointMake(32.47, 41.96) controlPoint2: CGPointMake(32.47, 48.54)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(51.42, 52.6) controlPoint1: CGPointMake(40.68, 56.67) controlPoint2: CGPointMake(47.32, 56.67)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(51.42, 37.9) controlPoint1: CGPointMake(55.53, 48.54) controlPoint2: CGPointMake(55.53, 41.96)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(36.58, 37.9) controlPoint1: CGPointMake(47.32, 33.83) controlPoint2: CGPointMake(40.68, 33.83)];
    [circularTubeDrawingPath closePath];
    [circularTubeDrawingPath moveToPoint: CGPointMake(62.74, 26.69)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(62.74, 63.81) controlPoint1: CGPointMake(73.09, 36.94) controlPoint2: CGPointMake(73.09, 53.56)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(25.26, 63.81) controlPoint1: CGPointMake(52.39, 74.06) controlPoint2: CGPointMake(35.61, 74.06)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(25.26, 26.69) controlPoint1: CGPointMake(14.91, 53.56) controlPoint2: CGPointMake(14.91, 36.94)];
    [circularTubeDrawingPath addCurveToPoint: CGPointMake(62.74, 26.69) controlPoint1: CGPointMake(35.61, 16.44) controlPoint2: CGPointMake(52.39, 16.44)];
    [circularTubeDrawingPath closePath];
    [[UIColor whiteColor] setFill];
    [circularTubeDrawingPath fill];
    
    //// Tube Extension Drawing Drawing
    UIBezierPath* tubeExtensionDrawingPath = [UIBezierPath bezierPathWithRect: CGRectMake(44, 19, 27, 14)];
    [[UIColor whiteColor] setFill];
    [tubeExtensionDrawingPath fill];
    
    //// Pump Cap Drawing Drawing
    UIBezierPath* pumpCapDrawingPath = [UIBezierPath bezierPathWithRect: CGRectMake(70, 17, 5, 18)];
    [[UIColor whiteColor] setFill];
    [pumpCapDrawingPath fill];    
    
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

@end

