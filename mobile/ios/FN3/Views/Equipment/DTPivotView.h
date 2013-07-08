//
//  DTPivotView.h
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEquipmentView.h"

@interface DTPivotView : UIView <DTEquipmentView> {
    UIColor *color;
    UIColor *directionMarkerColor;
    UIColor *borderColor;
    NSInteger borderWidth;
    
    BOOL partial;
    CGFloat partialStartAngle;
    CGFloat partialEndAngle;
    
    CGFloat trailStartAngle;
    CGFloat trailStopAngle;
    
    CGFloat currentAngle;
    CGFloat serviceAngle;
    
    DTEquipmentDirection direction;
}

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *directionMarkerColor;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic) NSInteger borderWidth;

@property (nonatomic) BOOL partial;
@property (nonatomic) CGFloat partialStartAngle;
@property (nonatomic) CGFloat partialEndAngle;
@property (nonatomic) CGFloat trailStartAngle;
@property (nonatomic) CGFloat trailStopAngle;
@property (nonatomic) CGFloat currentAngle;
@property (nonatomic) CGFloat serviceAngle;
@property (nonatomic) DTEquipmentDirection direction;

@end
