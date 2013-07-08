//
//  DTField.m
//  FN3
//
//  Created by David Jablonski on 4/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTField.h"

@implementation DTField

@synthesize permissions;

- (BOOL)isAvailable
{
    return (self.permissions & DTFieldPermissionAvailable) == DTFieldPermissionAvailable;
}

- (BOOL)isEditable
{
    return self.isAvailable && (self.permissions & DTFieldPermissionEditable) == DTFieldPermissionEditable;
}

- (void)setEditableFields:(NSSet *)editable availableFields:(NSSet *)available {
    self.permissions = DTFieldPermissionNone;
}

- (void)revert {
}

- (UIView *)inputAccessoryView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return nil;
    } else {
        return [super inputAccessoryView];
    }
}

- (BOOL)becomeFirstResponder
{
    BOOL val = [super becomeFirstResponder];
    if (val && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (!popoverController) {
            
            UIViewController *controller = [[UIViewController alloc] init];
            
            
            UIView *inputView = self.customInputView;
            UIView *inputAccessoryView = self.customInputAccessoryView;
            
            CGRect viewFrame = inputView.frame;
            viewFrame.size.height = inputView.frame.size.height + inputAccessoryView.frame.size.height;
            
            CGRect inputViewFrame = inputView.frame;
            inputViewFrame.origin.y = inputView.frame.origin.y + inputAccessoryView.frame.size.height;
            [inputView setFrame:inputViewFrame];
            
            [inputAccessoryView setFrame:CGRectMake(inputAccessoryView.frame.origin.x, inputAccessoryView.frame.origin.y, inputView.frame.size.width, inputAccessoryView.frame.size.height)];
            
            controller.view = [[UIView alloc] initWithFrame:viewFrame];
            [controller.view addSubview:inputView];
            [controller.view addSubview:inputAccessoryView];
            
            
            popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
            [popoverController setPopoverContentSize:controller.view.frame.size];
        }
        
        [popoverController presentPopoverFromRect:self.frame 
                                           inView:self.superview 
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    }
    return val;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [popoverController dismissPopoverAnimated:YES];
        return YES;
    } else {
        return NO;
    }
}

- (UIView *) customInputView
{
    return nil;
}


@end
