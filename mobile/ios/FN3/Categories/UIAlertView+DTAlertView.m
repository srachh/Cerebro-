//
//  UIAlertView+DTAlertView.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "UIAlertView+DTAlertView.h"
#import "DTResponse.h"

@implementation UIAlertView (DTAlertView)

+ (UIAlertView *)alertViewForNotConnectedToInternet
{
    return [[UIAlertView alloc] initWithTitle:nil
                                      message:NSLocalizedString(@"The network is not available", nil) 
                                     delegate:nil 
                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                            otherButtonTitles:nil];
}

+ (UIAlertView *)alertViewForNotAuthenticated
{
    return [[UIAlertView alloc] initWithTitle:nil
                                      message:NSLocalizedString(@"An authentication error occurred.  Please log in and try again.", nil)
                                     delegate:nil 
                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                            otherButtonTitles:nil];
}

+ (UIAlertView *)alertViewForResponse:(DTResponse *)response defaultMessage:(NSString *)defaultMessage
{
    NSString *message;
    if (response.errors.count > 0) {
        message = [response.errors lastObject];
    } else {
        message = defaultMessage;
    }
    
    return [[UIAlertView alloc] initWithTitle:nil
                                      message:message
                                     delegate:nil 
                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                            otherButtonTitles:nil];
}

@end
