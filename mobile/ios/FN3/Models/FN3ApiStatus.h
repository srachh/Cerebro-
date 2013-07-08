//
//  FN3ApiStatus.h
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FN3ApiStatus : NSObject <UIAlertViewDelegate> {
    BOOL isSuccess;
    NSInteger status;
    NSString *message;
}

+ (FN3ApiStatus *)instance;

- (BOOL)isActive;
- (void)prompt:(NSInteger)apiStatus;

- (void)setResponse:(id)response;

@end
