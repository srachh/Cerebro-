//
//  DTConnectionView.h
//  FN3
//
//  Created by David Jablonski on 3/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEquipment.h"

@interface DTConnectionView : UIView

@property (nonatomic) DTCommmStatus commStatus;
@property (nonatomic, retain) UIColor *accessoryColor;

@end
