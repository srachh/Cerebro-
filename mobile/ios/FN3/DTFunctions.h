//
//  DTFunctions.h
//  FN3
//
//  Created by David Jablonski on 2/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#ifndef FN3_DTFunctions_h
#define FN3_DTFunctions_h

#import <CoreGraphics/CoreGraphics.h>

extern CGFloat DTRadiansFromDegrees(CGFloat degrees);
extern CGFloat DTDegreesFromRadians(CGFloat radians);
extern CGPoint DTArcPoint(CGPoint center, CGFloat radius, CGFloat angle);

#endif
