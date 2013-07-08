//
//  DTSimpleBorder.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTBorder.h"

@interface DTSimpleBorder : NSObject <DTBorder> {
    UIColor *innerColor;
    UIColor *outerColor;
}

- (id)initWithOuterColor:(UIColor *)outerColor innerColor:(UIColor *)innerColor;

@property (nonatomic, retain) UIColor *outerColor;
@property (nonatomic, retain) UIColor *innerColor;

@end
