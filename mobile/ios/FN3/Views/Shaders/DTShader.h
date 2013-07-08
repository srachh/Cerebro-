//
//  DTShader.h
//  FN3
//
//  Created by David Jablonski on 3/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTShader <NSObject>

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect;

- (id<DTShader>)shaderWithAlpha:(CGFloat)alpha;

@end
