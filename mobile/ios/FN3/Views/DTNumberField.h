//
//  DTNumberField.h
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEditableView.h"
#import "DTKeypadView.h"
#import "DTField.h"

@interface DTNumberField : DTField <DTKeypadDelegate> {
    NSString *name;
    NSString *units;
    UILabel *label;
    
    NSString *value;
    CGFloat minValue;
    CGFloat maxValue;
    NSInteger decimalPlaces;
    NSInteger digits;
    
    BOOL waitingForFirstKey;
    NSNumber *valueBeforeEditing;
    
    NSInvocation *inputChangeListener;
}

@property (nonatomic) NSInteger digits;
@property (nonatomic) NSInteger decimalPlaces;
@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat maxValue;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSNumber * value;
@property (nonatomic, readonly) NSString *units;

@property (nonatomic, retain) NSString *nullDisplayText;

- (void)setValue:(NSNumber *)value units:(NSString *)units;

- (void)setInputChangeTarget:(id)target selector:(SEL)selector;

- (BOOL)isValid;

@end
