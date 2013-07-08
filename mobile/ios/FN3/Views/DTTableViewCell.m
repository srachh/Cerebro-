//
//  DTCellBackgroundView.m
//  FN3
//
//  Created by David Jablonski on 3/6/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTTableViewCell.h"
#include <math.h>

@implementation DTTableViewCell
@synthesize startColor, endColor;

- (void)setup
{
    self.startColor = [UIColor colorWithRed:.838 green:.838 blue:.838 alpha:1.0];
    self.endColor = [UIColor colorWithRed:0.988 green:.983 blue:.983 alpha:1.0];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (id)copyWithZone:(NSZone *)zone
{
    DTTableViewCell *copy = [[DTTableViewCell alloc] init];
    [copy setup];
    copy.frame = self.frame;
    copy.selectionStyle = self.selectionStyle;
    return copy;
}

- (void)drawGradientBackgroundInRect:(CGRect)bounds context:(CGContextRef)context
{
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, 83.0f, 106.0f);
	CFMutableArrayRef contexts = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	size_t bytesPerRow;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	CFMutableArrayRef colors;
	CGPoint point;
	CGPoint point2;
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGImageRef contextImage;
	unsigned char *pixels;
	CGFloat minX, maxX, minY, maxY;
	size_t width, height;
	CGFloat locations[2];
	
	transform = CGContextGetUserSpaceToDeviceSpaceTransform(context);
	resolution = sqrtf(fabsf(transform.a * transform.d - transform.b * transform.c)) * 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, bounds);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Setup for Inner Shadow Effect
	CFArrayAppendValue(contexts, context);
	bytesPerRow = 4 * roundf(bounds.size.width);
	context = CGBitmapContextCreate(NULL, roundf(bounds.size.width), roundf(bounds.size.height), 8, bytesPerRow, space, kCGImageAlphaPremultipliedLast);
	CGContextClipToRect(context, bounds);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Layer 1
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0f, 0.0f, 83.0f, 106.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = CFArrayCreateMutable(NULL, 2, &kCFTypeArrayCallBacks);
	CFArrayAppendValue(colors, self.startColor.CGColor);
	locations[0] = 0.0f;
	CFArrayAppendValue(colors, self.endColor.CGColor);
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
	
	// Inner Shadow Effect
	pixels = (unsigned char *)CGBitmapContextGetData(context);
	width = roundf(bounds.size.width);
	height = roundf(bounds.size.height);
	minX = width;
	maxX = -1.0f;
	minY = height;
	maxY = -1.0f;
	for (size_t row = 0; row < height; row++) {
		for (size_t column = 0; column < width; column++) {
			if (pixels[4 * (width * row + column) + 3] > 0) {
				minX = fminf(minX, (CGFloat)column);
				maxX = fmaxf(maxX, (CGFloat)column);
				minY = fminf(minY, (CGFloat)(height - row));
				maxY = fmaxf(maxY, (CGFloat)(height - row));
			}
		}
	}
	contextImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	context = (CGContextRef)CFArrayGetValueAtIndex(contexts, CFArrayGetCount(contexts) - 1);
	CFArrayRemoveValueAtIndex(contexts, CFArrayGetCount(contexts) - 1);
	CGContextDrawImage(context, imageBounds, contextImage);
    CGImageRelease(contextImage);
    
	CGContextSetAlpha(context, 0.696f);

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
	CFRelease(contexts);
}

- (void)drawRect:(CGRect)rect
{
    if (startColor && endColor) {
        UIGraphicsBeginImageContext(rect.size);
        [self drawGradientBackgroundInRect:rect context:UIGraphicsGetCurrentContext()];
        self.backgroundColor = [UIColor colorWithPatternImage:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
}

@end
