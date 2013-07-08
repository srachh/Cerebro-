//
//  DTSpeedDepthField.h
//  FieldNET
//
//  Created by Loren Davelaar on 10/2/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTNumberField.h"
@class DTSpeedDepthField;

@protocol DTSpeedDepthFieldDelegate <NSObject>
- (BOOL)speedDepthFieldShouldEndEditing:(DTSpeedDepthField *)speedDepthField;
@end

@interface DTSpeedDepthField : DTField <DTKeypadDelegate> {
    UISegmentedControl *segctrl;
    DTKeypadView *editKeypad;
    NSNumber *depthConversionFactor;
}

@property (nonatomic) BOOL isWaterOn;
@property (nonatomic) NSString *speedTitle;
@property (nonatomic) NSString *depthTitle;
@property (nonatomic, readonly) DTNumberField *speedField;
@property (nonatomic, readonly) DTNumberField *depthField;

@property (nonatomic, weak) id<DTSpeedDepthFieldDelegate> delegate;

- (void)setSpeed:(NSNumber *)value;
- (void)setDepthConversionFactor:(NSNumber *)value;
- (BOOL)isValid;
- (BOOL)isSpeedFieldSelected;

@end
