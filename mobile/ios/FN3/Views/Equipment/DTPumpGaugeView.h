//
//  DTPumpGaugeView.h
//  FN3
//
//  Created by David Jablonski on 4/11/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTGauge;

@interface DTPumpGaugeView : UIView {
    NSMutableArray *colors;
    NSMutableArray *startAngles;
    NSMutableArray *endAngles;
    
    NSMutableArray *markerColors;
    NSMutableArray *markerAngles;
    
    NSMutableArray *viewAngles;
    NSMutableArray *views;
    
    CGFloat needleAngle;
    
    CGFloat width;
    
}

@property (nonatomic) CGFloat needleAngle;
@property (nonatomic, readonly) UILabel *minValue;
@property (nonatomic, readonly) UILabel *maxValue;

- (void)addGaugeColor:(UIColor *)color fromAngle:(CGFloat)from toAngle:(CGFloat)to;
- (void)addText:(NSString *)label atAngle:(CGFloat)angle;
- (void)addView:(UIView *)view atAngle:(CGFloat)angle;
- (void)addMarkerWithColor:(UIColor *)color atAngle:(CGFloat)angle;

- (void)configureFromGauge:(DTGauge *)gauge;
- (void)reset;

@end
