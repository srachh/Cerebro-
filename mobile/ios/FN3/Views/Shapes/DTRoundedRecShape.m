//
//  DTRoundedRecShape.m
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTRoundedRecShape.h"
#import "DTFunctions.h"

@implementation DTRoundedRecShape
@synthesize roundedCorners, cornerRadius;

- (id)init
{
    return [self initWithRoundedCorners:DTRoundedCornerNone];
}

- (id)initWithRoundedCorners:(DTRoundedCorner)myRoundedCorners
{
    return [self initWithRoundedCorners:myRoundedCorners radius:10.0];
}

- (id)initWithRoundedCorners:(DTRoundedCorner)myRoundedCorners radius:(CGFloat)myRadius
{
    if (self = [super init]) {
        roundedCorners = myRoundedCorners;
        cornerRadius = myRadius;
    }
    return self;
}

- (void)dealloc
{
    roundedCorners = 0;
    cornerRadius = 0;
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect
{
    CGContextBeginPath(context);
    if ((self.roundedCorners & DTRoundedCornerAll) == DTRoundedCornerAll || (self.roundedCorners & DTRoundedCornerTopLeft) == DTRoundedCornerTopLeft) {
        CGPoint center = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y + self.cornerRadius);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + self.cornerRadius);
        CGContextAddArc(context, center.x, center.y, self.cornerRadius, DTRadiansFromDegrees(180), DTRadiansFromDegrees(270), NO);
    } else {
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    }
    
    if ((self.roundedCorners & DTRoundedCornerAll) == DTRoundedCornerAll || (self.roundedCorners & DTRoundedCornerTopRight) == DTRoundedCornerTopRight) {
        CGPoint center = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y + self.cornerRadius);
        CGContextAddArc(context, center.x, center.y, self.cornerRadius, DTRadiansFromDegrees(270), DTRadiansFromDegrees(0), NO);
    } else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    }
    
    if ((self.roundedCorners & DTRoundedCornerAll) == DTRoundedCornerAll || (self.roundedCorners & DTRoundedCornerBottomRight) == DTRoundedCornerBottomRight) {
        CGPoint center = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y + rect.size.height - self.cornerRadius);
        CGContextAddArc(context, center.x, center.y, self.cornerRadius, DTRadiansFromDegrees(0), DTRadiansFromDegrees(90), NO);
    } else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    }
    
    if ((self.roundedCorners & DTRoundedCornerAll) == DTRoundedCornerAll || (self.roundedCorners & DTRoundedCornerBottomLeft) == DTRoundedCornerBottomLeft) {
        CGPoint center = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y + rect.size.height - self.cornerRadius);
        CGContextAddArc(context, center.x, center.y, self.cornerRadius, DTRadiansFromDegrees(90), DTRadiansFromDegrees(180), NO);
    } else {
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    }
    CGContextClip(context);
}

@end
