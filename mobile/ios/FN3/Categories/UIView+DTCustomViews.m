//
//  UIView+DTPickerView.m
//  FN3
//
//  Created by David Jablonski on 4/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "UIView+DTCustomViews.h"

#import "DTView.h"
#import "DTLinearGradientShader.h"
#import "DTSimpleBorder.h"
#import "UIColor+DTColor.h"

@implementation UIView (DTCustomViews)

+ (id<DTShader>)blackGradientShader
{
    static dispatch_once_t pred = 0;
    __strong static id blackGradientShader = nil;
    dispatch_once(&pred, ^{
        blackGradientShader = [[DTLinearGradientShader alloc] initFromColor:[UIColor rgbBlackGradientColor] 
                                                                    toColor:[UIColor rgbBlackColor]];
    });
    return blackGradientShader;
}

+ (id<DTShader>)grayGradientShader
{
    static dispatch_once_t pred = 0;
    __strong static id grayGradientShader = nil;
    dispatch_once(&pred, ^{
        grayGradientShader = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.86 green:.86 blue:.86 alpha:1.0] 
                                                                   toColor:[UIColor colorWithRed:.76 green:.76 blue:.76 alpha:1.0]];
    });
    return grayGradientShader;
}

+ (id<DTBorder>)grayBorder
{
    static dispatch_once_t pred = 0;
    __strong static id grayBorder = nil;
    dispatch_once(&pred, ^{
        grayBorder = [[DTSimpleBorder alloc] initWithOuterColor:[UIColor colorWithRed:.53 green:.53 blue:.53 alpha:1.0] 
                                                     innerColor:[UIColor colorWithRed:.92 green:.92 blue:.92 alpha:1.0]];
    });
    return grayBorder;
}

+ (id<DTShader>)greenButtonShader
{
    static dispatch_once_t pred = 0;
    __strong static id greenButtonShader = nil;
    dispatch_once(&pred, ^{
        greenButtonShader = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.302 green:.659 blue:.263 alpha:1]
                                                                  toColor:[UIColor colorWithRed:.128 green:.404 blue:.188 alpha:1]];
    });
    return greenButtonShader;
}

+ (id<DTShader>)greenButtonHighlightedShader
{
    static dispatch_once_t pred = 0;
    __strong static id greenButtonHighlightedShader = nil;
    dispatch_once(&pred, ^{
        greenButtonHighlightedShader = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.141 green:.45 blue:.189 alpha:1]
                                                                             toColor:[UIColor colorWithRed:.303 green:.673 blue:.262 alpha:1]];
    });
    return greenButtonHighlightedShader;
}

+ (UIView *)tableHeaderViewWithTitle:(NSString *)title
{
    CGFloat padding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 15 : 50;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    container.backgroundColor = [UIColor clearColor];
    
    DTView *view = [[DTView alloc] init];
    view.frame = CGRectMake(padding, 5, container.frame.size.width - padding - padding, container.frame.size.height - 5);
    view.autoresizingMask = container.autoresizingMask;
    view.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor rgbBlackGradientColor]
                                                            toColor:[UIColor rgbBlackColor]];
    view.roundedCorners = DTViewRoundedCornerTopLeft | DTViewRoundedCornerTopRight;
    view.border = [[DTSimpleBorder alloc] initWithOuterColor:[UIColor rgbBlackHeaderGradientColor] 
                                                  innerColor:[UIColor rgbBlackGradientColor]];
    [container addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 
                                                               8, 
                                                               view.frame.size.width - 20, 
                                                               view.frame.size.height - 16)];
    label.text = title;
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = view.autoresizingMask;
    label.font = [label.font fontWithSize:14];
    label.numberOfLines = 0;
    label.tag = 1;
    [view addSubview:label];
    
    return container;
}

+ (UILabel *)equipmentNavigationTitleView
{
    UILabel *titleView = [[UILabel alloc] init];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleView.textColor = [UIColor whiteColor];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.lineBreakMode = UILineBreakModeMiddleTruncation;
    
    return titleView;
}

@end
