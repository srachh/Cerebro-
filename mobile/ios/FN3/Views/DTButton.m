//
//  DTButton.m
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTButton.h"

#import "DTShader.h"
#import "DTBorder.h"

@implementation DTButton

@synthesize background, border;
@synthesize selectedBackground, selectedBorder;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(redraw) forControlEvents:UIControlEventAllEvents];
}

- (void)redraw {
    [self setNeedsDisplay];
    [self performSelector:@selector(setNeedsDisplay) withObject:self afterDelay:0.15];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    if (self.state == UIControlStateHighlighted) {
        [self.selectedBackground drawInContext:context rect:rect];
        [self.selectedBorder drawInContext:context path:path rect:rect];
    } else {
        [self.background drawInContext:context rect:rect];
        [self.border drawInContext:context path:path rect:rect];
    }
}

@end
