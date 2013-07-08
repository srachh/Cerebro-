//
//  DTPumpStationView.h
//  FieldNET
//
//  Created by Loren Davelaar on 9/19/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEquipmentView.h"
#import "DTPumpStation.h"

@class DTPumpStation;

@interface DTPumpStationView : UIView <DTEquipmentView> {
    UIColor *color;
    UIColor *shadowColor;
    
    DTPumpState pumpState;
}

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic) DTPumpState pumpState;

- (void)configureFromPump:(DTPump  *)pump;

@end
