//
//  DTRectangleView.m
//  FN3
//
//  Created by David Jablonski on 2/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTLateralView.h"
#import "DTFunctions.h"
#import "DTLateral.h"
#import "UIColor+DTColor.h"
#import "NSArray+DTArray.h"


@implementation DTLateralView

@synthesize color, directionMarkerColor, borderColor, borderWidth;
@synthesize width, height, angle;
@synthesize positionPercent, trailStartPercent, trailStopPercent;
@synthesize serviceStopPercent;
@synthesize hoseStops;
@synthesize direction;
@synthesize detailLevel;
@synthesize positionColor;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor blueColor];
    self.directionMarkerColor = [UIColor whiteColor];
    self.borderWidth = 5;
}

- (id)copyWithZone:(NSZone *)zone
{
    DTLateralView *copy = [[DTLateralView alloc] initWithFrame:self.frame];
    copy.color = self.color;
    copy.directionMarkerColor = self.directionMarkerColor;
    copy.borderColor = self.borderColor;
    copy.borderWidth = self.borderWidth;
    
    copy.width = self.width;
    copy.height = self.height;
    copy.angle = self.angle;
    copy.positionPercent = self.positionPercent;
    copy.trailStartPercent = self.trailStartPercent;
    copy.trailStopPercent = self.trailStopPercent;
    copy.serviceStopPercent = self.serviceStopPercent;
    copy.hoseStops = self.hoseStops;
    
    copy.direction = self.direction;
    copy.detailLevel = self.detailLevel;
    copy.positionColor = self.positionColor;
    return copy;
}

- (void)configureFromEquipment:(DTEquipment *)equipment
{
    DTLateral *lateral = (DTLateral *)equipment;
    
    self.color = [UIColor colorFromHexString:lateral.color];
    self.borderColor = [self.color darkerColor];
    self.direction = lateral.direction;
    
    self.angle = lateral.angle.floatValue;

    self.width = lateral.mapWidthMeters.floatValue;
    self.height = lateral.mapHeightMeters.floatValue;
    if (self.width == 0 && self.height == 0) {
        self.width = 500;
        self.height = self.width * .75;
    } else if (self.width == 0) {
        self.width = self.height * 1.25;
    } else if (self.height == 0) {
        self.height = self.width * .75;
    }
    
    self.positionPercent = lateral.position ? lateral.position.floatValue / lateral.widthMeters.floatValue : -1;
    self.trailStartPercent = lateral.trailStart ? lateral.trailStart.floatValue / lateral.widthMeters.floatValue : -1;
    if (self.trailStartPercent > 1) {
        self.trailStartPercent = 1;
    }
    self.trailStopPercent = lateral.trailStop ? lateral.trailStop.floatValue / lateral.widthMeters.floatValue : -1;
    if (self.trailStopPercent > 1) {
        self.trailStopPercent = 1;
    }
    
    self.serviceStopPercent = lateral.servicePosition ? lateral.servicePosition.floatValue / lateral.widthMeters.floatValue : -1;
    
    self.hoseStops = [lateral.hoseStopPositionsArray collect:^id(NSNumber *value) {
        return [NSNumber numberWithFloat:value.floatValue / lateral.widthMeters.floatValue];
    }];
    
    self.positionColor = [UIColor whiteColor];
    
    [self setNeedsDisplay];
}

- (CGSize)size:(CGSize)currentSize scaledToSize:(CGSize)newSize
{
    if (currentSize.width == 0 || currentSize.height == 0) {
        return CGSizeZero;
    }
    
    CGFloat factor = MIN(newSize.width / currentSize.width, newSize.height / currentSize.height);
    return CGSizeMake(currentSize.width * factor, currentSize.height * factor);
}

- (void)drawRect:(CGRect)rect
{
    if (rect.size.width == 0 || rect.size.height == 0) {
        return;
    }
    
    CGSize size = CGSizeMake(width, height);
    if (self.detailLevel == DTEquipmentDetailLevelList) {
        size.height = size.width * .75;
    }
    
    CGFloat factor = MIN(rect.size.width / width, rect.size.height / height);
    size = CGSizeMake(size.width * factor, size.height * factor);
    
    rect = CGRectMake((self.borderWidth / 2.0f) + ((rect.size.width - size.width) / 2.0f),
                      (self.borderWidth / 2.0f) + ((rect.size.height - size.height) / 2.0f),
                      size.width - self.borderWidth,
                      size.height - self.borderWidth);
    
    if (self.detailLevel != DTEquipmentDetailLevelList && self.angle > 0) {
        CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2.0f), rect.origin.y + (rect.size.height / 2.0f));
        CGAffineTransform move = CGAffineTransformMakeTranslation(-center.x, -center.y);
        CGAffineTransform rotate = CGAffineTransformMakeRotation(DTRadiansFromDegrees(90 + self.angle));
        CGAffineTransform back = CGAffineTransformMakeTranslation(center.x, center.y);
        
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), back);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), rotate);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), move);
    }
    
    // draw the border
    UIBezierPath *outline = [UIBezierPath bezierPathWithRect:rect];
    outline.lineWidth = self.borderWidth;
    [self.color setStroke];
    [outline stroke];
    
    [self drawTrailInRect:rect];
    [self drawMarkersInRect:rect];
}

- (void)drawTrailInRect:(CGRect)rect
{
    if (trailStartPercent >= 0 && trailStopPercent >= 0) {
        CGFloat startX = rect.origin.x + ((rect.size.width - self.borderWidth) * self.trailStartPercent);
        CGFloat endX = rect.origin.x + ((rect.size.width - self.borderWidth) * self.trailStopPercent);
        
        CGRect fillRect = CGRectMake(startX,
                                     rect.origin.y + (self.borderWidth / 2.0),
                                     endX - startX,
                                     rect.size.height - self.borderWidth);
        UIBezierPath *fill = [UIBezierPath bezierPathWithRect:fillRect];
        [[self.color colorWithAlphaComponent:0.7] setFill];
        [fill fill];
        
        // add the trail start marker
        UIBezierPath *startMarker = [UIBezierPath bezierPath];
        [startMarker moveToPoint:fillRect.origin];
        [startMarker addLineToPoint:CGPointMake(fillRect.origin.x, fillRect.origin.y + fillRect.size.height)];
        [[UIColor yellowColor] setStroke];
        startMarker.lineWidth = self.borderWidth / 2.0;
        [startMarker stroke];
    }
}

- (void)drawMarkersInRect:(CGRect)rect
{
    if (positionPercent >= 0) {
        CGFloat x = rect.origin.x + ((rect.size.width - self.borderWidth) * self.positionPercent);
        
        UIBezierPath *positionPath = [UIBezierPath bezierPath];
        positionPath.lineWidth = self.borderWidth / 2.0f;
        
        [positionPath moveToPoint:CGPointMake(x, rect.origin.y + (self.borderWidth / 2.0f))];
        [positionPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - (self.borderWidth / 2.0f))];
        if (self.direction != DTEquipmentDirectionStopped) {
            CGFloat pointHeight = rect.size.height * .15;
            CGFloat pointWidth = pointHeight * 1.5;
            if (self.direction == DTEquipmentDirectionReverse) {
                pointWidth *= -1;
            }
            
            [positionPath moveToPoint:CGPointMake(x, CGRectGetMidY(rect) - (pointHeight / 2.0))];
            [positionPath addLineToPoint:CGPointMake(x + pointWidth, CGRectGetMidY(rect))];
            [positionPath addLineToPoint:CGPointMake(x, CGRectGetMidY(rect) + (pointHeight / 2.0))];
        }
        
        if (detailLevel == DTEquipmentDetailLevelMap) {
            [[UIColor blackColor] setStroke];
            [[UIColor blackColor] setFill];
        } else {
            //[[UIColor whiteColor] setStroke];
            //[[UIColor whiteColor] setFill];
            [self.positionColor setStroke];
            [self.positionColor setFill];
            
        }
        [positionPath stroke];
        [positionPath fill];
    }
    
    if (self.serviceStopPercent >= 0) {
        CGFloat x = rect.origin.x + ((rect.size.width - self.borderWidth) * self.serviceStopPercent);
        
        UIBezierPath *serviceStopPath = [UIBezierPath bezierPath];
        [serviceStopPath moveToPoint:CGPointMake(x, rect.origin.y + (self.borderWidth / 2.0f))];
        [serviceStopPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height - (self.borderWidth / 2.0))];
        serviceStopPath.lineWidth = self.borderWidth / 2.0f;
        
        CGFloat gapLength = (rect.size.height - self.borderWidth) / 6.0;
        CGFloat length = (rect.size.height - self.borderWidth - gapLength - gapLength) / 3.0;
        
        CGFloat pattern[5];
        pattern[0] = length;
        pattern[1] = gapLength;
        pattern[2] = length;
        pattern[3] = gapLength;
        pattern[4] = length;
        
        [serviceStopPath setLineDash:pattern count:5 phase:0];
        if (self.detailLevel == DTEquipmentDetailLevelMap) {
            [[UIColor blackColor] setStroke];
        } else if (self.detailLevel == DTEquipmentDetailLevelDetail) {
            [[UIColor whiteColor] setStroke];
        } else {
            [[UIColor grayColor] setStroke];
        }
        [serviceStopPath stroke];
    }
    
    if (self.detailLevel != DTEquipmentDetailLevelList && self.hoseStops.count > 0) {
        CGFloat y1 = rect.origin.y + rect.size.height - (borderWidth / 2.0f);
        CGFloat y2 = rect.origin.y + rect.size.height + (borderWidth / 2.0f);
        
        UIBezierPath *stopsPath = [UIBezierPath bezierPath];
        stopsPath.lineWidth = self.borderWidth / 2.0f;
        [[UIColor whiteColor] setStroke];
        
        for (NSNumber *stop in self.hoseStops) {
            CGFloat x = rect.origin.x + ((rect.size.width - self.borderWidth) * stop.floatValue);
            
            [stopsPath moveToPoint:CGPointMake(x, y1)];
            [stopsPath addLineToPoint:CGPointMake(x, y2)];
        }
        
        [stopsPath stroke];
    }
    
    if (self.detailLevel != DTEquipmentDetailLevelList) {
        CGFloat length = self.detailLevel == DTEquipmentDetailLevelMap ? self.borderWidth * .85 : self.borderWidth * .5;
        
        UIBezierPath *arrow = [UIBezierPath bezierPath];
        [arrow moveToPoint:CGPointMake(0, 0)];
        [arrow addLineToPoint:CGPointMake(length, length / 2.0f)];
        [arrow addLineToPoint:CGPointMake(0, length)];
        [arrow closePath];
        
        if (self.detailLevel == DTEquipmentDetailLevelDetail) {
            [[UIColor blackColor] setStroke];
            [[UIColor whiteColor] setFill];
        } else {
            [[UIColor whiteColor] setStroke];
            [[UIColor blackColor] setFill];
        }
        
        CGFloat moveAmount = length + 2;
        [arrow applyTransform:CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y + length)];
        
        for (int i = 0; i < 3; i++) {
            [arrow applyTransform:CGAffineTransformMakeTranslation(moveAmount, 0)];
            [arrow stroke];
            [arrow fill];
        }
    }
}

@end
