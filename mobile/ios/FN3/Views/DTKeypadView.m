//
//  DTKeypadView.m
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTKeypadView.h"

#import "DTButton.h"

#import "DTSolidShader.h"
#import "DTLinearGradientShader.h"
#import "DTSimpleBorder.h"

@implementation DTKeypadView
@synthesize view, decimalView, deleteView;
@synthesize delegate;

- (id)init
{
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"keypad" owner:self options:nil];
        
        id<DTShader> grayBackground = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.43 green:.45 blue:.51 alpha:1.0] 
                                                                            toColor:[UIColor colorWithRed:.31 green:.34 blue:.39 alpha:1.0]];
        id<DTBorder> grayBorder = [[DTSimpleBorder alloc] initWithOuterColor:[UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1]
                                                                  innerColor:[UIColor colorWithRed:.58 green:.6 blue:.64 alpha:1.0]];
        id<DTShader> selectedBackground = [[DTSolidShader alloc] initWithColor:[UIColor whiteColor]];
        
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[DTButton class]]) {
                DTButton *button = (DTButton *)v;
                button.background = grayBackground;
                button.border = grayBorder;
                
                button.selectedBackground = selectedBackground;
            }
        }
        
        self.decimalView.background = self.deleteView.background = [[DTLinearGradientShader alloc] initFromColor:[UIColor colorWithRed:.87 green:.87 blue:.87 alpha:1]
                                                                                                                                 toColor:[UIColor colorWithRed:.71 green:.72 blue:.75 alpha:1]];
        self.decimalView.border = self.deleteView.border = nil;
        self.decimalView.selectedBackground = self.deleteView.selectedBackground = grayBackground;
        self.decimalView.selectedBorder = self.deleteView.selectedBorder = grayBorder;
        self.decimalView.titleLabel.text = [[NSNumberFormatter alloc] decimalSeparator];
        
        self.frame = self.view.frame;
        [self addSubview:self.view];
    }
    return self;
}

- (id)initWithDelegate:(id<DTKeypadDelegate>)_delegate
{
    if ([self init]) {
        self.delegate = _delegate;
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow) {
        [delegate keypadDidAppear:self];
    } else {
        [delegate keypadDidDisappear:self];
    }
}

- (void)keyPressed:(id)sender
{
    if (delegate) {
        if (sender == self.deleteView) {
            [delegate keypadDelete:self];
        } else {
            [delegate keypad:self pressedKey:[sender titleForState:UIControlStateNormal]];
        }
    }
}

@end
