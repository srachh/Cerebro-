//
//  DTEditableView.h
//  FN3
//
//  Created by David Jablonski on 3/12/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTView.h"


enum {
    DTEditableViewStateNormal        = 0,
    DTEditableViewStateEditing       = 1,
    DTEditableViewStateSelected      = 2
};
typedef NSUInteger DTEditableViewState;


@class DTEditableView;

typedef void (^DTEditableViewChange)(DTEditableView *);


@interface DTEditableView : UIView {
    DTViewRoundedCorner roundedCorners;
    
    DTView *backgroundView;
    DTView *editingView;
    DTView *selectedView;
    
    UIView *editingAccessoryView;
    CGFloat editingAccessoryViewRightMargin;
    
    DTEditableViewState state;
    UIView *customInputView;
    UIView *customInputAccessoryView;
    
    NSInvocation *clickInvocation;
}

@property (nonatomic) DTViewRoundedCorner roundedCorners;

@property (nonatomic, retain) DTView *backgroundView;
@property (nonatomic, retain) DTView *editingView;
@property (nonatomic, retain) DTView *selectedView;

@property (nonatomic, retain) UIView *editingAccessoryView;
@property (nonatomic) CGFloat editingAccessoryViewRightMargin;

@property (nonatomic) DTEditableViewState state;
@property (nonatomic, copy) DTEditableViewChange viewChangeCallback;

@property (nonatomic, retain) UIView *customInputAccessoryView;;
@property (nonatomic, retain) UIView *customInputView;


- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)beginEditingAnimated:(BOOL)animated;
- (void)endEditingAnimated:(BOOL)animated;

@end
