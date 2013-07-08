//
//  UIAlertView+DTAlertView.h
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTResponse;

@interface UIAlertView (DTAlertView)

+ (UIAlertView *)alertViewForNotConnectedToInternet;

+ (UIAlertView *)alertViewForNotAuthenticated;

+ (UIAlertView *)alertViewForResponse:(DTResponse *)response defaultMessage:(NSString *)defaultMessage;

@end
