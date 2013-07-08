//
//  DTSolidShader.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTShader.h"

@interface DTSolidShader : NSObject <DTShader> {
    UIColor *color;
}

- (id)initWithColor:(UIColor *)color;

@property (nonatomic, retain) UIColor *color;

@end
