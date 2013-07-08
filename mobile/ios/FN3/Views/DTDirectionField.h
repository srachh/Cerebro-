//
//  DTDirectionField.h
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEditableView.h"
#import "DTField.h"

@interface DTDirectionField : DTField <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSString *direction;
    NSString *valueBeforeEditing;
    
    UIImageView *view;
}

@property (nonatomic) NSString *direction;
@property (nonatomic, retain) NSArray *availableDirectionsNames;
@property (nonatomic, retain) NSArray *availableDirectionsValues;
@property (nonatomic) Boolean isLateral;

@end
