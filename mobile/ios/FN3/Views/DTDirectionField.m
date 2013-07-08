//
//  DTDirectionField.m
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTDirectionField.h"
#import "DTLinearGradientShader.h"

#import "UIColor+DTColor.h"


NSString * const DTDirectionFieldName = @"directionSelect";
NSString * const DTDirectionOptionStarted = @"Start";
NSString * const DTDirectionOptionStopped = @"Stop";
NSString * const DTDirectionOptionForward = @"Forward";
NSString * const DTDirectionOptionReverse = @"Reverse";


@implementation DTDirectionField

@synthesize availableDirectionsNames, availableDirectionsValues, direction, isLateral;

- (void)awakeFromNib
{
    self.backgroundView.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor rgbBlackGradientColor] 
                                                                           toColor:[UIColor rgbBlackColor]];
    
    UIImage *image = [self imageForDirection:DTDirectionOptionForward black:NO];
    
    view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake((self.frame.size.width - image.size.width) / 2.0, 
                            (self.frame.size.height - image.size.height) / 2.0, 
                            image.size.width, 
                            image.size.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:view];
    
    valueBeforeEditing = nil;
}

- (void)beginEditingAnimated:(BOOL)animated
{
    [super beginEditingAnimated:animated];
    
    if (!valueBeforeEditing) {
        valueBeforeEditing = direction;
    }
}

- (void)revert
{
    [self setDirection:valueBeforeEditing];
}

- (void)endEditingAnimated:(BOOL)animated
{
    [super endEditingAnimated:animated];
    
    valueBeforeEditing = nil;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available
{
    permissions = 0;
    
    if ([editable containsObject:DTDirectionFieldName]) {
        permissions |= DTFieldPermissionEditable;
    }
    
    if ([available containsObject:DTDirectionFieldName]) {
        permissions |= DTFieldPermissionAvailable;
    }
    
    view.hidden = !self.isAvailable;
}

- (void)setDirection:(NSString *)_direction
{
    direction = _direction;
    view.image = [self imageForDirection:_direction black:NO];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return nil;
    } else {
        return self.customInputView;
    }
}

- (UIView *)customInputView
{
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [picker reloadAllComponents];
    
    if (self.availableDirectionsValues.count > 0) {
        [picker selectRow:[self.availableDirectionsValues indexOfObject:self.direction] inComponent:0 animated:NO];
    }
    
    return picker;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.availableDirectionsNames.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)resuseView
{
    NSString *name = [self.availableDirectionsNames objectAtIndex:row];
    NSString *value = [self.availableDirectionsValues objectAtIndex:row];
    UIImage *image = [self imageForDirection:value black:YES];
    NSString *title = NSLocalizedString(name, @"direction");
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                               0, 
                                                               pickerView.bounds.size.width, 
                                                               image.size.height + 20)];
    rowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(30, 
                                 (rowView.frame.size.height - image.size.height) / 2.0, 
                                 image.size.width, 
                                 image.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [rowView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width + 40, 
                                                               0, 
                                                               rowView.frame.size.width - image.size.width - 50, 
                                                               rowView.frame.size.height)];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [rowView addSubview:label];
    
    return rowView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    direction = [self.availableDirectionsValues objectAtIndex:row];
    view.image = [self imageForDirection:direction black:NO];
}

- (UIImage *)imageForDirection:(NSString *)_direction black:(BOOL)black
{
    if ([DTDirectionOptionForward isEqualToString:_direction]) {
        if (self.isLateral) {
            return black ? [UIImage imageNamed:@"lateral_forward_black.png"] : [UIImage imageNamed:@"lateral_forward.png"];
        }else {
            return black ? [UIImage imageNamed:@"forward_black.png"] : [UIImage imageNamed:@"forward.png"];
        }
    } else if ([DTDirectionOptionReverse isEqualToString:_direction]) {
        if (self.isLateral) {
            return black ? [UIImage imageNamed:@"lateral_reverse_black.png"] : [UIImage imageNamed:@"lateral_reverse.png"];
        } else {
            return black ? [UIImage imageNamed:@"reverse_black.png"] : [UIImage imageNamed:@"reverse.png"];
        }
    } else if ([DTDirectionOptionStarted isEqualToString:_direction]) {
        if (self.isLateral) {
            return black ? [UIImage imageNamed:@"lateral_started_black.png"] : [UIImage imageNamed:@"lateral_started.png"];
        } else {
            return black ? [UIImage imageNamed:@"started_black.png"] : [UIImage imageNamed:@"started.png"];
        }
    } else {
        return black ? [UIImage imageNamed:@"stop_black.png"] : [UIImage imageNamed:@"stop.png"];
    }
}

@end
