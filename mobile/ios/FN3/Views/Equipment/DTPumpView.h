//
//  DTPumpView.h
//  FN3
//
//  Created by David Jablonski on 2/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEquipmentView.h"
#import "DTPump.h"

@class DTPump;

@interface DTPumpView : UIView <DTEquipmentView> {
    UIColor *color;
    UIColor *shadowColor;
    
    DTPumpState pumpState;
}

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic) DTPumpState pumpState;

- (void)configureFromPump:(DTPump  *)pump;

@end
