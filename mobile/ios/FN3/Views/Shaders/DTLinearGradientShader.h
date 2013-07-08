//
//  DTLinearGradientShader.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTShader.h"


enum {
    DTLinearGradientOrientationVertical    = 0,
    DTLinearGradientOrientationHorizontal  = 1
};
typedef NSUInteger DTLinearGradientOrientation;


@interface DTLinearGradientShader : NSObject <DTShader> {
    DTLinearGradientOrientation orientation;
    NSMutableArray *colors;
    NSMutableArray *locations;
}

- (id)initFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;
- (id)initWithColors:(NSArray *)colors atLocations:(NSArray *)locations;

- (void)addColor:(UIColor *)color atLocation:(CGFloat)location;

@property (nonatomic) DTLinearGradientOrientation orientation;

@end
