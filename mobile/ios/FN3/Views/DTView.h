//
//  DTGradientView.h
//  FN3
//
//  Created by David Jablonski on 2/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTShader.h"
#import "DTBorder.h"


enum {
    DTViewRoundedCornerNone         = 0,
    DTViewRoundedCornerAll          = 1 << 0,
    DTViewRoundedCornerTopLeft      = 1 << 1,
    DTViewRoundedCornerTopRight     = 1 << 2,
    DTViewRoundedCornerBottomLeft   = 1 << 3,
    DTViewRoundedCornerBottomRight  = 1 << 4
};
typedef NSUInteger DTViewRoundedCorner;


@interface DTView : UIView {
    DTViewRoundedCorner roundedCorners;
    CGFloat cornerRadius;
    
    id<DTShader> background;
    id<DTBorder>border;
}

@property (nonatomic) DTViewRoundedCorner roundedCorners;
@property (nonatomic) CGFloat cornerRadius;

@property (nonatomic, retain) id<DTShader> background;
@property (nonatomic, retain) id<DTBorder> border;

@end
