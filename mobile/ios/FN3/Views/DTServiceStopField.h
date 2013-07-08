//
//  DTServiceStopField.h
//  FieldNET
//
//  Created by David Jablonski on 8/24/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTNumberField.h"
@class DTServiceStopField;

@protocol DTServiceStopFieldDelegate <NSObject>
- (BOOL)serviceStopFieldShouldEndEditing:(DTServiceStopField *)serviceStopField;
@end

@interface DTServiceStopField : DTNumberField <UITableViewDataSource, UITableViewDelegate> {
    DTFieldPermissions autoRepeatPermissions;
    UIImageView *autoRepeatView;
    
    BOOL autoRepeatOn;
    NSNumber *autoRepeatValueBeforeEditing;
}

@property (nonatomic, readonly) NSString *autoRepeatName;
@property (nonatomic) BOOL autoRepeat;
@property (nonatomic) BOOL isAutoRepeatAvailable;
@property (nonatomic) BOOL isAutoRepeatEditable;

@property (nonatomic, weak) id<DTServiceStopFieldDelegate> delegate;

- (BOOL)isValid;

@end
