//
//  DTGradientView.m
//  FN3
//
//  Created by David Jablonski on 2/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTView.h"
#import "DTFunctions.h"

@implementation DTView

@synthesize roundedCorners, cornerRadius;
@synthesize background, border;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.cornerRadius = 10;
}

- (void)dealloc
{
    roundedCorners = 0;
    cornerRadius = 0;
    
    self.background = nil;
    self.border = nil;
}

- (void)drawRect:(CGRect)rect;
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if ((self.roundedCorners & DTViewRoundedCornerAll) == DTViewRoundedCornerAll || (self.roundedCorners & DTViewRoundedCornerTopLeft) == DTViewRoundedCornerTopLeft) {
        CGPoint center = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y + self.cornerRadius);
        [path moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + self.cornerRadius)];
        [path addArcWithCenter:center radius:self.cornerRadius startAngle:DTRadiansFromDegrees(180) endAngle:DTRadiansFromDegrees(270) clockwise:YES];
    } else {
        [path moveToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
    }
    
    if ((self.roundedCorners & DTViewRoundedCornerAll) == DTViewRoundedCornerAll || (self.roundedCorners & DTViewRoundedCornerTopRight) == DTViewRoundedCornerTopRight) {
        CGPoint center = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y + self.cornerRadius);
        [path addArcWithCenter:center radius:self.cornerRadius startAngle:DTRadiansFromDegrees(270) endAngle:DTRadiansFromDegrees(0) clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    }
    
    if ((self.roundedCorners & DTViewRoundedCornerAll) == DTViewRoundedCornerAll || (self.roundedCorners & DTViewRoundedCornerBottomRight) == DTViewRoundedCornerBottomRight) {
        CGPoint center = CGPointMake(rect.origin.x + rect.size.width - self.cornerRadius, rect.origin.y + rect.size.height - self.cornerRadius);
        [path addArcWithCenter:center radius:self.cornerRadius startAngle:DTRadiansFromDegrees(0) endAngle:DTRadiansFromDegrees(90) clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    }
    
    if ((self.roundedCorners & DTViewRoundedCornerAll) == DTViewRoundedCornerAll || (self.roundedCorners & DTViewRoundedCornerBottomLeft) == DTViewRoundedCornerBottomLeft) {
        CGPoint center = CGPointMake(rect.origin.x + self.cornerRadius, rect.origin.y + rect.size.height - self.cornerRadius);
        [path addArcWithCenter:center radius:self.cornerRadius startAngle:DTRadiansFromDegrees(90) endAngle:DTRadiansFromDegrees(180) clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    }
    [path addClip];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (background) {
        [background drawInContext:context rect:rect];
    }

    if (border) {
        [border drawInContext:context path:path rect:rect];
    }
}

@end
