//
//  DTBorder.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTBorder <NSObject>

- (id<DTBorder>)borderWithAlpha:(CGFloat)alpha;

- (void)drawInContext:(CGContextRef)context path:(UIBezierPath *)path rect:(CGRect)rect;

@end
