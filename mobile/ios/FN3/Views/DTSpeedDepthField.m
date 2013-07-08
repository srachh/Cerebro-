//
//  DTSpeedDepthField.m
//  FieldNET
//
//  Created by Loren Davelaar on 10/2/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTView.h"
#import "DTSpeedDepthField.h"

#import "DTSolidShader.h"
#import "DTLinearGradientShader.h"
#import "DTSimpleBorder.h"

#import "UIView+DTCustomViews.h"

NSString * const DTSpeedPermission = @"applicationRate";
NSString * const DTDepthPermission = @"applicationDepth";

@implementation DTSpeedDepthField

@synthesize isWaterOn;
@synthesize speedTitle;
@synthesize depthTitle;
@synthesize speedField;
@synthesize depthField;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    speedField = [[DTNumberField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 2.0)];
    self.speedField.name = DTSpeedPermission;
    self.speedField.minValue = 1;
    self.speedField.maxValue = 100;
    self.speedField.decimalPlaces = 1;
    self.speedField.digits = 3;
    [self.speedField setInputChangeTarget:self selector:@selector(onRateOrDepthChange:)];
    self.speedField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.speedField];

    depthField = [[DTNumberField alloc] initWithFrame:CGRectMake(0, speedField.frame.size.height, self.frame.size.width, speedField.frame.size.height)];
    self.depthField.name = DTDepthPermission;
    // depthField.minValue will get changed when setDepthConversionFactor is called
    self.depthField.minValue = 0;
    self.depthField.maxValue = 999;
    self.depthField.digits = 3;
    self.depthField.decimalPlaces = 2;
    self.depthField.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    [self.depthField setInputChangeTarget:self selector:@selector(onRateOrDepthChange:)];
    self.depthField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.depthField];
    
    self.speedField.backgroundView = [[DTView alloc] initWithFrame:self.speedField.bounds];
    self.speedField.selectedView = [[DTView alloc] initWithFrame:self.speedField.bounds];
    self.speedField.editingView = [[DTView alloc] initWithFrame:self.speedField.bounds];
    
    self.depthField.backgroundView = [[DTView alloc] initWithFrame:self.depthField.bounds];
    self.depthField.selectedView = [[DTView alloc] initWithFrame:self.depthField.bounds];
    self.depthField.editingView = [[DTView alloc] initWithFrame:self.depthField.bounds];
    
    self.speedField.userInteractionEnabled = self.depthField.userInteractionEnabled = NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    if (self.delegate && ![self.delegate speedDepthFieldShouldEndEditing:self]) {
        return NO;
    } else {
        return [super resignFirstResponder];
    }
}

- (void)setSpeed:(NSNumber *)value
{
    [self.speedField setValue:value units:self.speedField.units];
    [self.depthField setValue:[self depthForRate:value] units:self.depthField.units];
}

- (void)setDepthConversionFactor:(NSNumber *)value
{
    depthConversionFactor = value;
    self.depthField.minValue = value.floatValue;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    [self.speedField setEditableFields:editable availableFields:available];
    [self.depthField setEditableFields:editable availableFields:available];
    self.permissions = self.speedField.permissions | self.depthField.permissions;
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    [self.speedField beginEditingAnimated:NO];
    [self.depthField beginEditingAnimated:NO]; 
    
    self.depthField.editingView.border = self.speedField.editingView.border = nil;
}

- (void)revert
{
    [self.speedField revert];
    [self.depthField revert];
    
    self.depthField.editingView.border = self.speedField.editingView.border = nil;
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    [self.speedField endEditingAnimated:NO];
    [self.depthField endEditingAnimated:NO];
    
    if (self.depthField.hidden) {
        if (self.depthField.isAvailable) {
            self.depthField.hidden = NO;
        }
    }
    
    self.depthField.editingView.border = self.speedField.editingView.border = nil;
}

- (UIView *)inputView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (customInputView) {
            UINavigationBar *bar = (UINavigationBar *)self.customInputAccessoryView;
            bar.topItem.title = speedTitle;
            segctrl.selectedSegmentIndex = 0;
            if (self.isWaterOn) {
                customInputView.frame = CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, editKeypad.frame.size.width, editKeypad.frame.size.height + segctrl.frame.size.height + 20);  
                editKeypad.frame = CGRectMake(0, segctrl.frame.origin.y + segctrl.frame.size.height + 10, editKeypad.frame.size.width, editKeypad.frame.size.height);
                segctrl.hidden = NO;
                self.depthField.hidden = NO;
            } else {
                customInputView.frame = CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, editKeypad.frame.size.width, editKeypad.frame.size.height);
                editKeypad.frame = CGRectMake(0, 0, editKeypad.frame.size.width, editKeypad.frame.size.height);
                segctrl.hidden = YES;
                self.depthField.hidden = YES;
            }
            
            CGRect viewFrame = customInputView.frame;
            viewFrame.size.height = customInputView.frame.size.height + customInputAccessoryView.frame.size.height;
            
            [popoverController setPopoverContentSize:viewFrame.size];
        }

        return nil;
    } else {
        return [super inputView];
    }
}

- (UIView *)customInputView
{
    if (!customInputView) {
        NSDictionary *segmentSelectedAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIFont boldSystemFontOfSize:14.0f], UITextAttributeFont,  nil];
        
        NSDictionary *segmentNonSelectedAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, [UIFont systemFontOfSize:14.0f], UITextAttributeFont,  nil];
        editKeypad = [[DTKeypadView alloc] initWithDelegate:self];
        editKeypad.tag = 1;
        
        NSString *leftTitle = speedTitle;
        NSString *rightTitle = depthTitle;
        
        if (speedTitle.length > 19) {
            leftTitle = [[speedTitle substringToIndex:16] stringByAppendingString:@"..."];
        }
        
        if (depthTitle.length > 19) {
            rightTitle = [[depthTitle substringToIndex:16] stringByAppendingString:@"..."]; 
        }
        
        NSArray *segmentItems = [NSArray arrayWithObjects:leftTitle, rightTitle, nil];
        segctrl = [[UISegmentedControl alloc] initWithItems:segmentItems];
        segctrl.frame = CGRectMake(10, 10, editKeypad.frame.size.width - 20, segctrl.frame.size.height);
        segctrl.selectedSegmentIndex = 0;
        [segctrl setTitleTextAttributes:segmentNonSelectedAttributes forState:UIControlStateNormal];
        [segctrl setTitleTextAttributes:segmentSelectedAttributes forState:UIControlStateSelected];
        //segctrl.segmentedControlStyle = UISegmentedControlStyleBar;
        //segctrl.segmentedControlStyle = UISegmentedControlStyleBezeled;
        //segctrl.segmentedControlStyle = UISegmentedControlStyleBordered;
        segctrl.segmentedControlStyle = UISegmentedControlStylePlain;
        
        [segctrl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                
        editKeypad.frame = (CGRect){
            .origin = CGPointMake(0, segctrl.frame.origin.y + segctrl.frame.size.height + 10),
            .size = editKeypad.frame.size
        };
        
        UIView *view = nil;
        
        if (self.isWaterOn) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, editKeypad.frame.size.width, editKeypad.frame.size.height + segctrl.frame.size.height + 20)];
            editKeypad.frame = CGRectMake(0, segctrl.frame.origin.y + segctrl.frame.size.height + 10, editKeypad.frame.size.width, editKeypad.frame.size.height);
            segctrl.hidden = NO;
            self.depthField.hidden = NO;
        } else {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, editKeypad.frame.size.width, editKeypad.frame.size.height)];
            editKeypad.frame = CGRectMake(0, 0, editKeypad.frame.size.width, editKeypad.frame.size.height);
            segctrl.hidden = YES;
            self.depthField.hidden = YES;
        }
        
        view.backgroundColor = [UIColor darkGrayColor];
        [view addSubview:editKeypad];
        [view addSubview:segctrl];
        view.autoresizesSubviews = YES;
        
        customInputView = view;
        customInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    } else {
        UINavigationBar *bar = (UINavigationBar *)self.customInputAccessoryView;
        bar.topItem.title = speedTitle;
        segctrl.selectedSegmentIndex = 0;
        
        if (self.isWaterOn) {
            customInputView.frame = CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, editKeypad.frame.size.width, editKeypad.frame.size.height + segctrl.frame.size.height + 20);  
            editKeypad.frame = CGRectMake(0, segctrl.frame.origin.y + segctrl.frame.size.height + 10, editKeypad.frame.size.width, editKeypad.frame.size.height);
            segctrl.hidden = NO;
            self.depthField.hidden = NO;
        } else {
            customInputView.frame = CGRectMake(customInputView.frame.origin.x, customInputView.frame.origin.y, editKeypad.frame.size.width, editKeypad.frame.size.height);
            editKeypad.frame = CGRectMake(0, 0, editKeypad.frame.size.width, editKeypad.frame.size.height);
            segctrl.hidden = YES;
            self.depthField.hidden = YES;
        }
    }
    
    return customInputView;
    
}

- (IBAction)valueChanged:(id)sender
{
    UINavigationBar *bar = (UINavigationBar *)self.customInputAccessoryView;
    if ([sender selectedSegmentIndex] == 0) {
        bar.topItem.title = speedTitle;
        
        [self.speedField keypadDidAppear:(DTKeypadView *)[customInputView viewWithTag:1]];
        [self.depthField keypadDidDisappear:(DTKeypadView *)[customInputView viewWithTag:1]];
    } else {
        bar.topItem.title = depthTitle;
        
        [self.depthField keypadDidAppear:(DTKeypadView *)[customInputView viewWithTag:1]];
        [self.speedField keypadDidDisappear:(DTKeypadView *)[customInputView viewWithTag:1]];
    }
}

- (void)onRateOrDepthChange:(DTNumberField *)field
{
    if (field == self.speedField) {
        [self.depthField setValue:[self depthForRate:field.value] units:self.depthField.units];
    } else if (field == self.depthField) {
        [self.speedField setValue:[self rateForDepth:field.value] units:self.speedField.units];
    }
}

- (NSNumber *)depthForRate:(NSNumber *)rate
{
    CGFloat depth;
    if (rate.floatValue > 0) {
        depth = (depthConversionFactor.floatValue * 100.0) / rate.floatValue;
    } else {
        depth = 0;
    }
    
    return [NSNumber numberWithFloat:depth];
}

- (NSNumber *)rateForDepth:(NSNumber *)depth
{
    CGFloat rate;
    if (depth.floatValue > 0) {
        rate = (depthConversionFactor.floatValue / depth.floatValue) * 100.0;
        if (rate > 0 && rate < 1) {
            rate = 1;
        } else if (rate > 100) {
            rate = 100;
        }
    } else {
        rate = 0;
    }
    return [NSNumber numberWithFloat:rate];
}

-(BOOL)isValid
{
    if (self.isWaterOn) {
        return (([self.speedField isValid]) && ([self.depthField isValid]));
    } else {
        return [self.speedField isValid];
    }
}

-(BOOL)isSpeedFieldSelected
{
    return segctrl.selectedSegmentIndex == 0;
}

#pragma mark - keyboard notifications
- (void)keypadDidAppear:(DTKeypadView *)keypad
{
    if (self.isWaterOn) {
        if (segctrl.selectedSegmentIndex == 0) {
            [self.speedField keypadDidAppear:keypad];
        } else {
            [self.depthField keypadDidAppear:keypad];
        }
    } else {
        [self.speedField keypadDidAppear:keypad];
    }
        
}
- (void)keypadDidDisappear:(DTKeypadView *)keypad
{
    if (self.isWaterOn) {
        if (segctrl.selectedSegmentIndex == 0) {
            [self.speedField keypadDidDisappear:keypad];
        } else {
            [self.depthField keypadDidDisappear:keypad];
        }
    } else {
        [self.speedField keypadDidDisappear:keypad];
    }
}
- (void)keypad:(DTKeypadView *)keypad pressedKey:(NSString *)key
{
    if (self.isWaterOn) {
        if (segctrl.selectedSegmentIndex == 0) {
            [self.speedField keypad:keypad pressedKey:key];
        } else {
            [self.depthField keypad:keypad pressedKey:key];
        }
    } else {
        [self.speedField keypad:keypad pressedKey:key];
    }
}
- (void)keypadDelete:(DTKeypadView *)keypad
{
    if (self.isWaterOn) {
        if (segctrl.selectedSegmentIndex == 0) {
            [self.speedField keypadDelete:keypad];
        } else {
            [self.depthField keypadDelete:keypad];
        }
    } else {
        [self.speedField keypadDelete:keypad];
    }
}

@end
