//
//  DTPlanField.h
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEditableView.h"
#import "DTField.h"
#import <CoreData/CoreData.h>

@class DTPlanSelectField, DTPlan, DTPersistentStore;

@protocol DTPlanSelectFieldDelegate <NSObject>
- (void)planSelectField:(DTPlanSelectField *)planField selectedPlan:(DTPlan *)plan;
@end


@interface DTPlanSelectField : DTField <UIPickerViewDelegate, UIPickerViewDataSource> {
    id<DTPlanSelectFieldDelegate> delegate;
    
    UIImageView *imageView;
    UILabel *label;
    
    DTPersistentStore *store;
    NSFetchedResultsController *resultsController;
    
    NSNumber *planIdBeforeEditing;
    NSString *planStepBeforeEditing;
}

@property (nonatomic, retain) id<DTPlanSelectFieldDelegate> delegate;
@property (nonatomic, readonly) NSString *driver;
@property (nonatomic, readonly) NSNumber *planId;
@property (nonatomic, readonly) NSString *planStep;

- (void)setDriver:(NSString *)driver planId:(NSNumber *)planId step:(NSString *)step;

@end
