//
//  DTMessageCountView.m
//  FN3
//
//  Created by David Jablonski on 3/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTMessageCountView.h"
#include <math.h>

@implementation DTMessageCountView

const CGFloat kDTMessageCountWidth = 41.0f;
const CGFloat kDTMessageCountHeight = 41.0f;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)bounds
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, kDTMessageCountWidth, kDTMessageCountHeight);
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	CFMutableArrayRef colors;
	CGColorRef color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
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
	
	// Layer 1
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0f, 0.0f, 41.0f, 41.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = CFArrayCreateMutable(NULL, 2, &kCFTypeArrayCallBacks);
    components[0] = 0.5f;
	components[1] = 0.5f;
	components[2] = 0.5f;
	components[3] = 1.0f;
	color = CGColorCreate(space, components);
	CFArrayAppendValue(colors, color);
	CGColorRelease(color);
	locations[0] = 0.0f;
	components[0] = 0.65f;
	components[1] = 0.65f;
	components[2] = 0.65f;
	components[3] = 1.0f;
	color = CGColorCreate(space, components);
	CFArrayAppendValue(colors, color);
	CGColorRelease(color);
	locations[1] = 1.0f;
	gradient = CGGradientCreateWithColors(space, colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571f);
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
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
    
    [super drawRect:bounds];
}

@end
