//
//  DTToggleField.h
//  FN3
//
//  Created by David Jablonski on 5/31/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTField.h"
@class DTToggleField;

@protocol DTToggleFieldDelegate <NSObject>
- (BOOL)toggleFieldShouldEndEditing:(DTToggleField *)toggleField;
@end

@interface DTToggleField : DTField <UITableViewDelegate, UITableViewDataSource> {
    UIImageView *view;
    
    BOOL on;
    NSNumber *valueBeforeEditing;
    NSInvocation *inputChangeListener;
}

@property (nonatomic) BOOL on;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) UIImage *offImage;
@property (nonatomic, retain) UIImage *onImage;
@property (nonatomic, retain) UIImage *toggleImage;

@property (nonatomic, weak) id<DTToggleFieldDelegate> delegate;

- (void)setInputChangeTarget:(id)target selector:(SEL)selector;

@end
