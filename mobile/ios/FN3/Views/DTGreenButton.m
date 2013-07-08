//
//  DTGreenButton.m
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTGreenButton.h"
#include <math.h>

@implementation DTGreenButton

const CGFloat kLoginButtonGradientWidth = 340.0f;
const CGFloat kLoginButtonGradientHeight = 159.0f;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(redraw) forControlEvents:UIControlEventAllEvents];
    self.backgroundColor = [UIColor clearColor];    
}

- (void)redraw {
    [self setNeedsDisplay];
    [self performSelector:@selector(setNeedsDisplay) withObject:self afterDelay:0.15];
}

- (void)drawButtonInContext:(CGContextRef)context inBounds:(CGRect)bounds flag:(BOOL)highlighted
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kLoginButtonGradientWidth, kLoginButtonGradientHeight);
	CGColorRef color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGFloat resolution;
	CGFloat alignStroke;
	CGMutablePathRef path;
	CGPoint point;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGGradientRef gradient;
	CFMutableArrayRef colors;
	CGPoint point2;
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGFloat components[4];
	CGFloat locations[2];
	
	transform = CGContextGetUserSpaceToDeviceSpaceTransform(context);
	resolution = sqrtf(fabsf(transform.a * transform.d - transform.b * transform.c)) * 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, bounds);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Setup for Shadow Effect
    components[0] = 0.0f;
	components[1] = 0.0f;
	components[2] = 0.0f;
	components[3] = 0.272f;
    color = CGColorCreate(space, components);
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f * resolution, 0.0f * resolution), 5.103f * resolution, color);
	CGColorRelease(color);
	CGContextBeginTransparencyLayer(context, NULL);
    
    alignStroke = 0.0f;
    path = CGPathCreateMutable();
    point = CGPointMake(321.0f, 148.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    point = CGPointMake(331.0f, 138.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    controlPoint1 = CGPointMake(326.486f, 148.0f);
    controlPoint2 = CGPointMake(331.0f, 143.486f);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    point = CGPointMake(331.0f, 21.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    point = CGPointMake(321.0f, 11.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    controlPoint1 = CGPointMake(331.0f, 15.514f);
    controlPoint2 = CGPointMake(326.486f, 11.0f);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    point = CGPointMake(19.0f, 11.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    point = CGPointMake(9.0f, 21.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    controlPoint1 = CGPointMake(13.514f, 11.0f);
    controlPoint2 = CGPointMake(9.0f, 15.514f);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    point = CGPointMake(9.0f, 138.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    point = CGPointMake(19.0f, 148.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    controlPoint1 = CGPointMake(9.0f, 143.486f);
    controlPoint2 = CGPointMake(13.514f, 148.0f);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    point = CGPointMake(321.0f, 148.0f);
    point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
    point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    CGPathCloseSubpath(path);
    
    if (highlighted) {
        components[0] = 0.141f;
		components[1] = 0.45f;
		components[2] = 0.189f;
		components[3] = 1.0f;
    } else {
        components[0] = 0.302f;
		components[1] = 0.659f;
		components[2] = 0.263f;
		components[3] = 1.0f;
    }
    
    colors = CFArrayCreateMutable(NULL, 2, &kCFTypeArrayCallBacks);
    color = CGColorCreate(space, components);
    CFArrayAppendValue(colors, color);
    CGColorRelease(color);
    
    locations[0] = 0.0f;
    if (highlighted) {
        components[0] = 0.303f;
        components[1] = 0.673f;
        components[2] = 0.262f;
        components[3] = 1.0f;
    } else {
        locations[0] = 0.0f;
        components[0] = 0.128f;
        components[1] = 0.404f;
        components[2] = 0.188f;
        components[3] = 1.0f;
    }

    color = CGColorCreate(space, components);
    CFArrayAppendValue(colors, color);
    CGColorRelease(color);
    locations[1] = 1.0f;
    gradient = CGGradientCreateWithColors(space, colors, locations);
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextEOClip(context);
    transform = CGAffineTransformMakeRotation(-1.571f);
    tempPath = CGPathCreateMutable();
    CGPathAddPath(tempPath, &transform, path);
    pathBounds = CGPathGetPathBoundingBox(tempPath);
    point = pathBounds.origin;
    point2 = CGPointMake(CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds));
    transform = CGAffineTransformInvert(transform);
    point = CGPointApplyAffineTransform(point, transform);
    point2 = CGPointApplyAffineTransform(point2, transform);
    CGPathRelease(tempPath);
    CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
    CGContextRestoreGState(context);
    CFRelease(colors);
    CGGradientRelease(gradient);
    CGPathRelease(path);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

- (void)drawRect:(CGRect)rect
{
    [self drawButtonInContext:UIGraphicsGetCurrentContext() 
                     inBounds:rect 
                         flag:self.state == UIControlStateHighlighted];
}

@end
