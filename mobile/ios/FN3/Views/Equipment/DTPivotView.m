//
//  DTPivotView.m
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPivotView.h"
#import "DTFunctions.h"
#import "DTPivot.h"
#import "UIColor+DTColor.h"


struct DTPivotArc {
    CGPoint center;
    CGFloat radius;
};
typedef struct DTPivotArc DTPivotArc;


@implementation DTPivotView

@synthesize color, directionMarkerColor, borderColor, borderWidth;
@synthesize partial, partialStartAngle, partialEndAngle, trailStartAngle, trailStopAngle;
@synthesize currentAngle, serviceAngle, direction;
@synthesize detailLevel;

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.directionMarkerColor = [UIColor whiteColor];
    self.borderWidth = 5;
}

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



- (id)copyWithZone:(NSZone *)zone
{
    DTPivotView *copy = [[DTPivotView alloc] initWithFrame:self.frame];
    copy.color = self.color;
    copy.directionMarkerColor = self.directionMarkerColor;
    copy.borderColor = self.borderColor;
    copy.borderWidth = self.borderWidth;
    copy.partial = self.partial;
    copy.partialStartAngle = self.partialStartAngle;
    copy.partialEndAngle = self.partialEndAngle;
    copy.trailStartAngle = self.trailStartAngle;
    copy.trailStopAngle = self.trailStopAngle;
    copy.currentAngle = self.currentAngle;
    copy.serviceAngle = self.serviceAngle;
    copy.direction = self.direction;
    copy.detailLevel = self.detailLevel;
    return copy;
}

- (void)configureFromEquipment:(DTEquipment *)equipment
{
    DTPivot *pivot = (DTPivot *)equipment;
    
    self.color = [UIColor colorFromHexString:pivot.color];
    //self.borderColor = [[self.color darkerColor] darkerColor];
    self.borderColor = self.color;
    
    self.partial = [pivot.partial boolValue];
    self.partialStartAngle = DTRadiansFromDegrees(pivot.partialStart.floatValue);
    self.partialEndAngle = DTRadiansFromDegrees(pivot.partialEnd.floatValue);
    
    self.trailStartAngle = DTRadiansFromDegrees(pivot.trailStart.floatValue);
    self.trailStopAngle = DTRadiansFromDegrees(pivot.trailStop.floatValue);
    
    self.currentAngle = pivot.position ? DTRadiansFromDegrees(pivot.position.floatValue) : -1;
    self.serviceAngle = pivot.servicePosition ? DTRadiansFromDegrees(pivot.servicePosition.floatValue) : -1;
    
    self.direction = pivot.direction;
    
    [self setNeedsDisplay];
}

- (void)fillCompletedForArc:(DTPivotArc)arc
{   
    UIColor *fillColor = self.color;
    UIColor *strokeColor = self.borderColor;
    fillColor = [self.color colorWithAlphaComponent:0.7];
    strokeColor = self.color;
    
    // draw the filled portion
    UIBezierPath *filled = [UIBezierPath bezierPath];
    [filled moveToPoint:arc.center];
    if (abs(trailStopAngle) > DTRadiansFromDegrees(360)) {
        [filled addArcWithCenter:arc.center 
                          radius:arc.radius 
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    } else {
        [filled addArcWithCenter:arc.center 
                          radius:arc.radius 
                      startAngle:trailStartAngle
                        endAngle:trailStartAngle + trailStopAngle
                       clockwise:trailStopAngle >= 0];
    }
    [filled closePath];
    [fillColor setFill];
    [filled fill];
    
    
    // draw the ring around the entire circle
    UIBezierPath *total = [UIBezierPath bezierPath];
    if (self.partial) {
        [total moveToPoint:arc.center];
        [total addArcWithCenter:arc.center 
                         radius:arc.radius 
                     startAngle:partialStartAngle 
                       endAngle:partialEndAngle 
                      clockwise:YES];
        [total addLineToPoint:arc.center];
    } else {
        [total addArcWithCenter:arc.center 
                         radius:arc.radius 
                     startAngle:0
                       endAngle:M_PI * 2
                      clockwise:YES];
    }
    [total setLineWidth:self.borderWidth];
    [strokeColor setStroke];
    [total stroke];
}

- (void)drawMarkersForArc:(DTPivotArc)arc centerArc:(DTPivotArc)centerArc
{
    DTPivotArc innerArc = {
        .center = arc.center,
        .radius = arc.radius - (self.borderWidth / 2)
    };
    
    if (trailStartAngle != trailStopAngle) {
        UIBezierPath *trailStart = [UIBezierPath bezierPath];
        [trailStart moveToPoint:DTArcPoint(innerArc.center, innerArc.radius, trailStartAngle)];
        [trailStart addLineToPoint:innerArc.center];
        [[UIColor yellowColor] setStroke];
        trailStart.lineWidth = self.borderWidth / 2.0;
        [trailStart stroke];
    }
    
    if (serviceAngle >= 0) {
        UIBezierPath *serviceStop = [UIBezierPath bezierPath];
        [serviceStop moveToPoint:DTArcPoint(innerArc.center, innerArc.radius, serviceAngle)];
        [serviceStop addLineToPoint:DTArcPoint(centerArc.center, centerArc.radius, serviceAngle)];
        [serviceStop setLineWidth:self.borderWidth / 2.0];
        
        CGFloat gapLength = (innerArc.radius - centerArc.radius) / 4.0;
        CGFloat length = (innerArc.radius - centerArc.radius - gapLength - gapLength) / 3.0;
        
        CGFloat pattern[5];
        pattern[0] = length;
        pattern[1] = gapLength;
        pattern[2] = length;
        pattern[3] = gapLength;
        pattern[4] = length;
        
        [serviceStop setLineDash:pattern count:5 phase:0];
        if (self.detailLevel == DTEquipmentDetailLevelMap) {
            [[UIColor blackColor] setStroke];
        } else if (self.detailLevel == DTEquipmentDetailLevelDetail) {
            [[UIColor whiteColor] setStroke];
        } else {
            [[UIColor grayColor] setStroke];
        }
        [serviceStop stroke];
    }
    
    // draw the current position marker and the flag
    if (self.currentAngle >= 0) {
        DTPivotArc endArc = {
            .center = arc.center,
            .radius = arc.radius - MIN(arc.radius / 10.0, self.borderWidth)
        };
        
        UIBezierPath *directionalMarker = [UIBezierPath bezierPath];
        [directionalMarker moveToPoint:arc.center];
        [directionalMarker addLineToPoint:DTArcPoint(endArc.center, endArc.radius, currentAngle)];
        [directionalMarker setLineWidth:self.borderWidth / 2.0];
        
        if (direction != DTEquipmentDirectionStopped) {
            CGFloat flagLength = endArc.radius / (self.detailLevel == DTEquipmentDetailLevelList ? 1.8 : 3.0);
            DTPivotArc startArc = {
                .center = arc.center,
                .radius = endArc.radius - flagLength
            };
            DTPivotArc tipArc = {
                .center = arc.center,
                .radius = endArc.radius - (flagLength / 2.0)
            };
            CGFloat tipAddAngle = DTRadiansFromDegrees(self.detailLevel == DTEquipmentDetailLevelList ? 22 : 12);
            if (direction == DTEquipmentDirectionReverse) {
                tipAddAngle = -(tipAddAngle);
            }
            
            [directionalMarker moveToPoint:DTArcPoint(startArc.center, startArc.radius, currentAngle)];
            [directionalMarker addLineToPoint:DTArcPoint(tipArc.center, tipArc.radius, currentAngle + tipAddAngle)];
            [directionalMarker addLineToPoint:DTArcPoint(endArc.center, endArc.radius, currentAngle)];
        }
        
        UIColor *c = self.detailLevel == DTEquipmentDetailLevelDetail ? self.directionMarkerColor : [UIColor blackColor];
        [c setFill];
        [directionalMarker fill];
        [c setStroke];
        [directionalMarker stroke];
    }
}

/*
 * Draws the white center with a black dot in the middle
 */
- (void)drawCenterArc:(DTPivotArc)centerArc
{
    UIBezierPath *outer = [UIBezierPath bezierPathWithArcCenter:centerArc.center 
                                                         radius:centerArc.radius
                                                     startAngle:0 
                                                       endAngle:2 * M_PI 
                                                      clockwise:YES];
    [outer setLineWidth:1];
    if (detailLevel == DTEquipmentDetailLevelList) {
        [[UIColor blackColor] setStroke];
    } else {
        [self.borderColor setStroke];
    }
    
    [self.directionMarkerColor setFill];
    [outer fill];
    [outer stroke];
    
    if (detailLevel != DTEquipmentDetailLevelList) {
        CGFloat innerRadius = centerArc.radius / 3;
        UIBezierPath *inner = [UIBezierPath bezierPathWithArcCenter:centerArc.center 
                                                             radius:innerRadius 
                                                         startAngle:0 
                                                           endAngle:2 * M_PI 
                                                          clockwise:YES];
        [inner setLineWidth:1.0];
        [[UIColor blackColor] setFill];
        [inner fill];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (rect.size.width == 0 || rect.size.height == 0) {
        return;
    }
    
    CGRect drawRect = CGRectMake(self.borderWidth / 2.0, 
                                 self.borderWidth / 2.0, 
                                 rect.size.width - self.borderWidth, 
                                 rect.size.height - self.borderWidth);
    
    DTPivotArc pivotArc = { .radius = drawRect.size.width / 2 };
    pivotArc.center = CGPointMake(drawRect.origin.x + pivotArc.radius, drawRect.origin.y + pivotArc.radius);
    
    DTPivotArc centerArc = {
        .center = pivotArc.center,
        .radius = pivotArc.radius / 10.0
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(context, DTRadiansFromDegrees(270));
    CGContextTranslateCTM(context, -self.frame.size.height, 0);
    
    [self fillCompletedForArc:pivotArc];
    [self drawMarkersForArc:pivotArc centerArc:centerArc];
    [self drawCenterArc:centerArc];
}



@end
