//
//  DTNumberField.m
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTNumberField.h"
#import "DTLinearGradientShader.h"
#import "DTSimpleBorder.h"
#import "DTKeypadView.h"

@implementation DTNumberField

@synthesize name;
@synthesize digits, decimalPlaces;
@synthesize minValue, maxValue;
@synthesize units;
@synthesize nullDisplayText;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 
                                                      4, 
                                                      self.frame.size.width - 20, 
                                                      self.frame.size.height - 8)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:label];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)customInputView
{
    if (!customInputView) {
        customInputView = [[DTKeypadView alloc] initWithDelegate:self];
    }
    return customInputView;
}

- (UIView *)inputView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return nil;
    } else {
        return self.customInputView;
    }
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    label.textColor = [UIColor whiteColor];
    
    if (!valueBeforeEditing) {
        valueBeforeEditing = self.value;
    }
}

- (void)revert
{
    [self setValue:valueBeforeEditing units:units];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    label.textColor = [UIColor blackColor];
    
    valueBeforeEditing = nil;
}

- (NSNumber *)value
{
    if (value.length == 0) {
        return nil;
    } else {
        return [NSNumber numberWithFloat:value.floatValue];
    }
}

- (void)setValue:(NSNumber *)_value units:(NSString *)_units
{
    units = _units;
    
    if (_value) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumIntegerDigits = self.digits;
        formatter.maximumFractionDigits = self.decimalPlaces;
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        value = [formatter stringFromNumber:_value];
    } else {
        value = nil;
    }
    
    if (value.length > 0) {
        label.text = [NSString stringWithFormat:@"%@%@", value, units];
    } else if (self.nullDisplayText) {
        label.text = [NSString stringWithFormat:@"%@%@", self.nullDisplayText, units];
    } else {
        label.text = nil;
    }
    
}

- (void)setInputChangeTarget:(id)target selector:(SEL)selector
{
    NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
    inputChangeListener = [NSInvocation invocationWithMethodSignature:sig];
    inputChangeListener.target = target;
    inputChangeListener.selector = selector;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    self.permissions = DTFieldPermissionNone;
    
    if ([editable containsObject:self.name]) {
        self.permissions |= DTFieldPermissionEditable;
    }
    
    if ([available containsObject:self.name]) {
        self.permissions |= DTFieldPermissionAvailable;
    }
    
    label.hidden = !self.isAvailable;
}

-(BOOL)isValid
{
    return [self isValidValue:self.value];
}

- (BOOL)isValidValue:(NSNumber *)_value
{
    //return _value == 0 || (_value >= minValue && _value <= maxValue);
    if (_value == nil) {
        return YES;
    } else {
        return _value.floatValue >= minValue && _value.floatValue <= maxValue;
    }
    
}

- (void)keypadDidAppear:(DTKeypadView *)keypad
{
    waitingForFirstKey = YES;
    label.textColor = [UIColor lightGrayColor];
}

- (void)keypad:(DTKeypadView *)keypad pressedKey:(NSString *)key
{
    if (waitingForFirstKey) {
        value = nil;
        label.textColor = [UIColor whiteColor];
        
        waitingForFirstKey = NO;
    }
    
    NSString *decimal = [[NSNumberFormatter alloc] decimalSeparator];
    // if there's already a decimal place, ignore it
    if ([decimal isEqualToString:key] && value && [value rangeOfString:key].location != NSNotFound) {
        return; 
    }
    
    NSMutableString *text = [[NSMutableString alloc] init];
    if (value.length > 0) {
        [text appendString:value];
    }
    
    // make sure we're not adding too many digits after the decimal point
    NSRange decimalPlace = [text rangeOfString:decimal];
    if (decimalPlace.location != NSNotFound) {
        NSInteger numberOfDecimalPlaces = text.length - decimalPlace.location - 1;
        if (numberOfDecimalPlaces == self.decimalPlaces) {
            return;
        }
    } else if (text.length > 0 && text.floatValue == 0 && [@"0" isEqualToString:key]) {
        // trying to enter multiple '0's before the decimal point
        return;
    }
    
    [text appendString:key];
    
    value = text;
    label.text = [NSString stringWithFormat:@"%@%@", value, units];
        
    if ([self isValidValue:[[NSNumber alloc] initWithFloat:text.floatValue]]) {
        label.textColor = [UIColor whiteColor];
    } else {
        label.textColor = [UIColor redColor];
    }
    
    id this = self;
    [inputChangeListener setArgument:&this atIndex:2];
    [inputChangeListener invoke];
}

- (void)keypadDelete:(DTKeypadView *)keypad
{
    if (waitingForFirstKey || value.length == 0) {
        value = nil;
        label.textColor = [UIColor whiteColor];
    } else {
        value = [value substringToIndex:value.length - 1];
    }
    
    if (value.length > 0) {
        label.text = [NSString stringWithFormat:@"%@%@", value, units];
    } else if (self.nullDisplayText) {
        label.text = [NSString stringWithFormat:@"%@%@", self.nullDisplayText, units];
    } else {
        label.text = nil;
    }
    
    if ([self isValidValue:value]) {
        label.textColor = [UIColor whiteColor];
    } else {
        label.textColor = [UIColor redColor];
    }
    
    id this = self;
    [inputChangeListener setArgument:&this atIndex:2];
    [inputChangeListener invoke];
}

- (void)keypadDidDisappear:(DTKeypadView *)keypad
{
    if (self.state == DTEditableViewStateEditing) {
        label.textColor = [UIColor whiteColor];
    }
    waitingForFirstKey = NO;
}


@end
