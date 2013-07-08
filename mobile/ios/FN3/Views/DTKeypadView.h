//
//  DTKeypadView.h
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTKeypadView;

@protocol DTKeypadDelegate <NSObject>
- (void)keypadDidAppear:(DTKeypadView *)keypad;
- (void)keypadDidDisappear:(DTKeypadView *)keypad;
- (void)keypad:(DTKeypadView *)keypad pressedKey:(NSString *)key;
- (void)keypadDelete:(DTKeypadView *)keypad;
@end


@class DTButton;

@interface DTKeypadView : UIView {
    id<DTKeypadDelegate> delegate;
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet DTButton *decimalView;
@property (weak, nonatomic) IBOutlet DTButton *deleteView;

@property (nonatomic, retain) id<DTKeypadDelegate> delegate;

- (id)initWithDelegate:(id<DTKeypadDelegate>)delegate;

- (IBAction)keyPressed:(id)sender;

@end
