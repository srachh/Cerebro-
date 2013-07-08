//
//  UIView+DTPickerView.h
//  FN3
//
//  Created by David Jablonski on 4/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTShader, DTBorder;

@interface UIView (DTCustomViews)

+ (id<DTShader>)blackGradientShader;
+ (id<DTShader>)grayGradientShader;
+ (id<DTBorder>)grayBorder;

+ (id<DTShader>)greenButtonShader;
+ (id<DTShader>)greenButtonHighlightedShader;

+ (UIView *)tableHeaderViewWithTitle:(NSString *)title;

+ (UILabel *)equipmentNavigationTitleView;

@end
