//
//  DTRectangleView.h
//  FN3
//
//  Created by David Jablonski on 2/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEquipmentView.h"


@interface DTLateralView : UIView <DTEquipmentView>

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *directionMarkerColor;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic) NSInteger borderWidth;

@property (nonatomic) CGFloat width, height, angle;
@property (nonatomic) CGFloat positionPercent, trailStartPercent, trailStopPercent;
@property (nonatomic) CGFloat serviceStopPercent;
@property (nonatomic, retain) NSArray *hoseStops;

@property (nonatomic) DTEquipmentDirection direction;

@property (nonatomic) UIColor *positionColor;

@end
