//
//  DTEditableView.m
//  FN3
//
//  Created by David Jablonski on 3/12/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEditableView.h"
#import "DTView.h"
#import "UIColor+DTColor.h"
#import "DTLinearGradientShader.h"
#import "DTSolidShader.h"
#import "DTSimpleBorder.h"
#import "DTFocusBorder.h"

@implementation DTEditableView

@synthesize roundedCorners;
@synthesize backgroundView, editingView, selectedView, viewChangeCallback;
@synthesize editingAccessoryView, editingAccessoryViewRightMargin;
@synthesize state;
@synthesize customInputAccessoryView, customInputView;

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    // by default, make it a solid black
    self.backgroundView = [[DTView alloc] init];
    self.backgroundView.background = [[DTSolidShader alloc] initWithColor:[UIColor rgbBlackColor]];
    
    self.selectedView = [[DTView alloc] init];
    selectedView.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.02 green:.55 blue:.96 alpha:1.0] 
                                                                    toColor:[UIColor colorWithRed:0.0 green:.37 blue:.9 alpha:1.0]];
    
    self.editingView = [[DTView alloc] init];
    editingView.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.07 green:.47 blue:.35 alpha:1.0] 
                                                                   toColor:[UIColor colorWithRed:0 green:.33 blue:.23 alpha:1.0]];
    editingView.border = [[DTSimpleBorder alloc] initWithOuterColor:[UIColor colorWithRed:.10 green:.27 blue:.21 alpha:1.0] 
                                                         innerColor:[UIColor colorWithRed:.32 green:.49 blue:.45 alpha:1.0]];
    
    self.editingAccessoryViewRightMargin = 8;
}

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.backgroundView = self.editingView = self.selectedView = nil;
    self.editingAccessoryView = nil;
    self.viewChangeCallback = nil;
}

- (void)setBackgroundView:(DTView *)aBackgroundView
{
    backgroundView = aBackgroundView;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.roundedCorners = self.roundedCorners;
    [self addSubview:backgroundView];
}

- (void)setSelectedView:(DTView *)aSelectedView
{
    selectedView = aSelectedView;
    selectedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    selectedView.roundedCorners = self.roundedCorners;
}

- (void)setEditingView:(DTView *)aEditingView
{
    editingView = aEditingView;
    editingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    editingView.roundedCorners = self.roundedCorners;
}

- (void)setRoundedCorners:(DTViewRoundedCorner)corners
{
    roundedCorners = corners;
    self.backgroundView.roundedCorners = self.editingView.roundedCorners = self.selectedView.roundedCorners = corners;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    
    if (view == backgroundView || view == editingView || view == selectedView) {
        [self sendSubviewToBack:view];
    }
}

- (void)layoutSubviews
{
    backgroundView.frame = editingView.frame = selectedView.frame = self.bounds;
    
    [super layoutSubviews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == DTEditableViewStateEditing) {
        self.state = DTEditableViewStateSelected;
        
        self.selectedView.frame = self.bounds;
        
        if (self.editingAccessoryView) {
            [self.selectedView addSubview:self.editingAccessoryView];
        }
        
        [self addSubview:self.selectedView];
        [self sendSubviewToBack:self.editingView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == DTEditableViewStateSelected) {
        self.state = DTEditableViewStateEditing;
        
        if (self.editingAccessoryView) {
            [self.editingView addSubview:self.editingAccessoryView];
        }
        
        [self.selectedView removeFromSuperview];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == DTEditableViewStateSelected) {
        self.state = DTEditableViewStateEditing;
    
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.editingView removeFromSuperview];
            
            if (self.editingAccessoryView) {
                [self.editingView addSubview:self.editingAccessoryView];
            }
            [UIView transitionFromView:[self.subviews objectAtIndex:0]
                                toView:self.editingView 
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL finished){
                            }];
        });
        
        [self becomeFirstResponder];
        
        if (clickInvocation) {
            [clickInvocation invoke];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return state == DTEditableViewStateEditing && self.customInputView != nil;
}

- (BOOL)becomeFirstResponder
{
    
    
    if ([self canBecomeFirstResponder] && [super becomeFirstResponder]) {
        self.editingView.border = [[DTFocusBorder alloc] init];
        [self.editingView setNeedsDisplay];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    if ([self canBecomeFirstResponder]) {
        editingView.border = [[DTSimpleBorder alloc] initWithOuterColor:[UIColor colorWithRed:.10 green:.27 blue:.21 alpha:1.0] 
                                                             innerColor:[UIColor colorWithRed:.32 green:.49 blue:.45 alpha:1.0]];
        [self.editingView setNeedsDisplay];
    }
    
    return [super resignFirstResponder];
}

- (UIView *)inputView
{
    if (self.customInputView) {
        return self.customInputView;
    } else {
        return nil;
    }
}

- (UIView *)inputAccessoryView
{
    return self.customInputAccessoryView;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        [self beginEditingAnimated:animated];
    } else {
        [self endEditingAnimated:animated];
    }
}

- (void)beginEditingAnimated:(BOOL)animated
{
    if (self.state == DTEditableViewStateNormal) {
        self.state = DTEditableViewStateEditing;
        
        if (self.viewChangeCallback) {
            self.viewChangeCallback(self);
        }
        
        self.editingView.frame = self.bounds;
        
        if (self.editingAccessoryView) {
            self.editingAccessoryView.frame = CGRectMake(self.editingView.frame.size.width - self.editingAccessoryView.frame.size.width - self.editingAccessoryViewRightMargin, 
                                                         (self.editingView.frame.size.height - self.editingAccessoryView.frame.size.height) / 2.0, 
                                                         self.editingAccessoryView.frame.size.width, 
                                                         self.editingAccessoryView.frame.size.height);
            [self.editingView addSubview:self.editingAccessoryView];
        }
        
        if (animated) {
            [UIView transitionFromView:[self.subviews objectAtIndex:0]
                                toView:self.editingView 
                              duration:0.4 
                               options:UIViewAnimationOptionTransitionFlipFromBottom
                            completion:^(BOOL finished){}];
        } else {
            [[self.subviews objectAtIndex:0] removeFromSuperview];
            [self addSubview:self.editingView];
        }
    }
}

- (void)endEditingAnimated:(BOOL)animated
{
    if (self.state == DTEditableViewStateEditing) {
        self.state = DTEditableViewStateNormal;
        
        if (self.viewChangeCallback) {
            self.viewChangeCallback(self);
        }
        
        self.backgroundView.frame = self.bounds;
        if (animated) {
            [UIView transitionFromView:[self.subviews objectAtIndex:0]
                                toView:self.backgroundView
                              duration:0.4 
                               options:UIViewAnimationOptionTransitionFlipFromBottom
                            completion:^(BOOL finished){}];
        } else {
            [[self.subviews objectAtIndex:0] removeFromSuperview];
            [self addSubview:self.backgroundView];
        }
        
        [self resignFirstResponder];
    }
}

@end
