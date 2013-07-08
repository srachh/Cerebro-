//
//  DTRoundedRecShape.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTShape.h"


enum {
    DTRoundedCornerNone         = 0,
    DTRoundedCornerAll          = 1 << 0,
    DTRoundedCornerTopLeft      = 1 << 1,
    DTRoundedCornerTopRight     = 1 << 2,
    DTRoundedCornerBottomLeft   = 1 << 3,
    DTRoundedCornerBottomRight  = 1 << 4
};
typedef NSUInteger DTRoundedCorner;


@interface DTRoundedRecShape : NSObject <DTShape> {
    DTRoundedCorner roundedCorners;
    CGFloat cornerRadius;
}

- (id)initWithRoundedCorners:(DTRoundedCorner)roundedCorners;
- (id)initWithRoundedCorners:(DTRoundedCorner)roundedCorners radius:(CGFloat)radius;

@property (nonatomic) DTRoundedCorner roundedCorners;
@property (nonatomic) CGFloat cornerRadius;

@end
