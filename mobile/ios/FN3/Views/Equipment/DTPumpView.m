//
//  DTPumpView.m
//  FN3
//
//  Created by David Jablonski on 2/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPumpView.h"
#import "DTPumpStation.h"
#import "UIColor+DTColor.h"
#import "DTPump.h"

@implementation DTPumpView

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
    DTPumpView *copy = [[DTPumpView alloc] initWithFrame:self.frame];
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
	CGContextScaleCTM(UIGraphicsGetCurrentContext(), rect.size.width / 65, rect.size.height / 65);
    
    //// Pump Dark Gray Base Drawing
    UIBezierPath* pumpDarkGrayBasePath = [UIBezierPath bezierPath];
    [pumpDarkGrayBasePath moveToPoint: CGPointMake(7.5, 53.5)];
    [pumpDarkGrayBasePath addLineToPoint: CGPointMake(14.5, 49.5)];
    [pumpDarkGrayBasePath addLineToPoint: CGPointMake(51.5, 49.5)];
    [pumpDarkGrayBasePath addCurveToPoint: CGPointMake(57.5, 53.5) controlPoint1: CGPointMake(51.5, 49.5) controlPoint2: CGPointMake(57.77, 53.5)];
    [pumpDarkGrayBasePath addCurveToPoint: CGPointMake(57, 65) controlPoint1: CGPointMake(57.23, 53.5) controlPoint2: CGPointMake(57, 65.19)];
    [pumpDarkGrayBasePath addCurveToPoint: CGPointMake(7.5, 65.5) controlPoint1: CGPointMake(57, 64.81) controlPoint2: CGPointMake(7.5, 65.5)];
    [pumpDarkGrayBasePath addLineToPoint: CGPointMake(7.5, 53.5)];
    [pumpDarkGrayBasePath closePath];
    [self.shadowColor setFill];
    [pumpDarkGrayBasePath fill];
    
    
    
    //// Pump Circular Tube Drawing
    UIBezierPath* pumpCircularTubePath = [UIBezierPath bezierPath];
    [pumpCircularTubePath moveToPoint: CGPointMake(24.58, 26.58)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(24.58, 41.42) controlPoint1: CGPointMake(20.47, 30.68) controlPoint2: CGPointMake(20.47, 37.32)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(39.42, 41.42) controlPoint1: CGPointMake(28.68, 45.53) controlPoint2: CGPointMake(35.32, 45.53)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(39.42, 26.58) controlPoint1: CGPointMake(43.53, 37.32) controlPoint2: CGPointMake(43.53, 30.68)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(24.58, 26.58) controlPoint1: CGPointMake(35.32, 22.47) controlPoint2: CGPointMake(28.68, 22.47)];
    [pumpCircularTubePath closePath];
    [pumpCircularTubePath moveToPoint: CGPointMake(50.74, 15.26)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(50.74, 52.74) controlPoint1: CGPointMake(61.09, 25.61) controlPoint2: CGPointMake(61.09, 42.39)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(13.26, 52.74) controlPoint1: CGPointMake(40.39, 63.09) controlPoint2: CGPointMake(23.61, 63.09)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(13.26, 15.26) controlPoint1: CGPointMake(2.91, 42.39) controlPoint2: CGPointMake(2.91, 25.61)];
    [pumpCircularTubePath addCurveToPoint: CGPointMake(50.74, 15.26) controlPoint1: CGPointMake(23.61, 4.91) controlPoint2: CGPointMake(40.39, 4.91)];
    [pumpCircularTubePath closePath];
    [self.color setFill];
    [pumpCircularTubePath fill];
    
    
    
    //// Pump Top Main Tube Extension Drawing
    UIBezierPath* pumpTopMainTubeExtensionPath = [UIBezierPath bezierPathWithRect: CGRectMake(32, 8, 27, 14)];
    [self.color setFill];
    [pumpTopMainTubeExtensionPath fill];
    
    
    
    //// Pump Cap Ending Drawing
    UIBezierPath* pumpCapEndingPath = [UIBezierPath bezierPathWithRect: CGRectMake(58, 6, 5, 18)];
    [self.color setFill];
    [pumpCapEndingPath fill];
    
    if (self.pumpState == DTPumpStateLocked) {
        UIColor* padlockDarkGray = [UIColor colorWithRed: 0.27 green: 0.27 blue: 0.29 alpha: 1];
        UIColor* padlockBottomYellow = [UIColor colorWithRed: 1 green: 0.85 blue: 0.08 alpha: 1];
        
        //// Padlock Top Gray Box Drawing
        UIBezierPath* padlockTopGrayBoxPath = [UIBezierPath bezierPathWithRect: CGRectMake(33, 44, 29, 11)];
        [padlockDarkGray setFill];
        [padlockTopGrayBoxPath fill];
        
        
        
        //// Padlock Bottom Yellow Box Drawing
        UIBezierPath* padlockBottomYellowBoxPath = [UIBezierPath bezierPathWithRect: CGRectMake(33, 55, 29, 10)];
        [padlockBottomYellow setFill];
        [padlockBottomYellowBoxPath fill];
        
        
        
        //// Packlock 3rd Angled Black Drawing
        UIBezierPath* packlock3rdAngledBlackPath = [UIBezierPath bezierPath];
        [packlock3rdAngledBlackPath moveToPoint: CGPointMake(55, 65)];
        [packlock3rdAngledBlackPath addLineToPoint: CGPointMake(60.23, 65)];
        [packlock3rdAngledBlackPath addLineToPoint: CGPointMake(51, 55)];
        [packlock3rdAngledBlackPath addLineToPoint: CGPointMake(45.77, 55)];
        [packlock3rdAngledBlackPath addLineToPoint: CGPointMake(55, 65)];
        [packlock3rdAngledBlackPath closePath];
        [[UIColor blackColor] setFill];
        [packlock3rdAngledBlackPath fill];
        
        
        
        //// Packlock 2nd Angled Black Drawing
        UIBezierPath* packlock2ndAngledBlackPath = [UIBezierPath bezierPath];
        [packlock2ndAngledBlackPath moveToPoint: CGPointMake(44, 65)];
        [packlock2ndAngledBlackPath addLineToPoint: CGPointMake(49.23, 65)];
        [packlock2ndAngledBlackPath addLineToPoint: CGPointMake(40, 55)];
        [packlock2ndAngledBlackPath addLineToPoint: CGPointMake(34.77, 55)];
        [packlock2ndAngledBlackPath addLineToPoint: CGPointMake(44, 65)];
        [packlock2ndAngledBlackPath closePath];
        [[UIColor blackColor] setFill];
        [packlock2ndAngledBlackPath fill];
        
        
        
        //// Packlock 4th Angled Black Drawing
        UIBezierPath* packlock4thAngledBlackPath = [UIBezierPath bezierPath];
        [packlock4thAngledBlackPath moveToPoint: CGPointMake(62, 61)];
        [packlock4thAngledBlackPath addLineToPoint: CGPointMake(62, 55)];
        [packlock4thAngledBlackPath addLineToPoint: CGPointMake(56.77, 55)];
        [packlock4thAngledBlackPath addLineToPoint: CGPointMake(62, 61)];
        [packlock4thAngledBlackPath closePath];
        [[UIColor blackColor] setFill];
        [packlock4thAngledBlackPath fill];
        
        
        
        //// Packlock 1st Angled Black Drawing
        UIBezierPath* packlock1stAngledBlackPath = [UIBezierPath bezierPath];
        [packlock1stAngledBlackPath moveToPoint: CGPointMake(33, 65)];
        [packlock1stAngledBlackPath addLineToPoint: CGPointMake(38.23, 65)];
        [packlock1stAngledBlackPath addLineToPoint: CGPointMake(33, 59)];
        [packlock1stAngledBlackPath addLineToPoint: CGPointMake(33, 65)];
        [packlock1stAngledBlackPath closePath];
        [[UIColor blackColor] setFill];
        [packlock1stAngledBlackPath fill];
        
        
        
        //// Padlock Top Ring Drawing
        UIBezierPath* padlockTopRingPath = [UIBezierPath bezierPath];
        [padlockTopRingPath moveToPoint: CGPointMake(37.5, 44.5)];
        [padlockTopRingPath addCurveToPoint: CGPointMake(46.89, 32.08) controlPoint1: CGPointMake(37.5, 44.5) controlPoint2: CGPointMake(36.76, 32.12)];
        [padlockTopRingPath addCurveToPoint: CGPointMake(57.5, 44.5) controlPoint1: CGPointMake(58.09, 32.03) controlPoint2: CGPointMake(57.1, 44.5)];
        padlockTopRingPath.lineCapStyle = kCGLineCapRound;
        [padlockDarkGray setStroke];
        padlockTopRingPath.lineWidth = 4;
        [padlockTopRingPath stroke];        
    } else if (self.pumpState == DTPumpStatePressurizing) {
        //// Yellow Box Drawing
        UIBezierPath* yellowBoxPath = [UIBezierPath bezierPathWithRect: CGRectMake(33, 45, 29, 21)];
        [[UIColor colorWithRed: 1 green: 0.85 blue: 0.08 alpha: 1] setFill];
        [yellowBoxPath fill];
        
        
        //// Letter P Drawing
        CGRect letterPFrame = CGRectMake(38, 45, 20, 22);
        [[UIColor blackColor] setFill];
        [@"P" drawInRect: letterPFrame withFont: [UIFont fontWithName: @"ArialMT" size: 20] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
    } else if (self.pumpState == DTPumpStateRegulating) {
        //// Yellow Box Drawing
        UIBezierPath* yellowBoxPath = [UIBezierPath bezierPathWithRect: CGRectMake(33, 45, 29, 21)];
        [[UIColor colorWithRed: 0.42 green: 0.14 blue: 0.53 alpha: 1] setFill];
        [yellowBoxPath fill];
        
        
        //// Letter R Drawing
        CGRect letterRFrame = CGRectMake(38, 45, 20, 22);
        [[UIColor whiteColor] setFill];
        [@"R" drawInRect: letterRFrame withFont: [UIFont fontWithName: @"ArialMT" size: 20] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
    }
    
    
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

@end
