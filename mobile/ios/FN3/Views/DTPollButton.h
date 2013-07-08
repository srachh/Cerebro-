//
//  DTPollButton.h
//  FN3
//
//  Created by David Jablonski on 5/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTShader;
@class DTNetworkBlockOperation;

@interface DTPollButton : UIButton {
    id<DTShader> disabledShader;
    BOOL isSpinning;
    
    NSInvocation *pollCompleteCallback;
    NSOperation *pollOperation;
    NSOperation *feedbackOperation;
    
    BOOL isInPollError;
}

@property (nonatomic, readonly) BOOL isPolling;
@property (nonatomic) BOOL isInPollError;

- (void)setPollCompleteTarget:(id)target selector:(SEL)selector;
- (void)pollEquipmentId:(NSNumber *)equipmentId;
- (void)pollEquipmentId:(NSNumber *)equipmentId functionId:(NSNumber *)functionId;
- (void)stop;

@end
