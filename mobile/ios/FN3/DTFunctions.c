//
//  DTFunctions.c
//  FN3
//
//  Created by David Jablonski on 2/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <stdio.h>
#import <math.h>
#import "DTFunctions.h"


CGFloat DTRadiansFromDegrees(CGFloat degrees) {
    return degrees * M_PI / 180.0;
}

CGFloat DTDegreesFromRadians(CGFloat radians) {
    return radians / M_PI * 180.0;
}

CGPoint DTArcPoint(CGPoint center, CGFloat radius, CGFloat angle) {
    // account for arc coordinates start being off by 90 degrees and rotating the oppisite direction
    angle = DTRadiansFromDegrees(90) - angle;
    
    return CGPointMake(center.x + radius * sin(angle), center.y + radius * cos(angle));
}
