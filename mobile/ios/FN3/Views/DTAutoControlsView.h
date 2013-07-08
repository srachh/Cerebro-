//
//  DTAutoControlsView.h
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTEditableView.h"
#import "DTField.h"

@class DTAutoControlsViewField;

@interface DTAutoControlsView : DTField <UITableViewDataSource, UITableViewDelegate> {
    DTAutoControlsViewField *autoReverseField, *autoRestartField;
    NSMutableArray *visibleControls;
}

@property (nonatomic) BOOL autoReverse;
@property (nonatomic) BOOL autoRestart;

@end
