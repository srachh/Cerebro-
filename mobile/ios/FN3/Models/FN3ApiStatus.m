//
//  FN3ApiStatus.m
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "FN3ApiStatus.h"
#import "DTCredentials.h"
#import "DTConnection.h"

NSString * const APP_ITUNES_LINK = @"itms-apps://itunes.com/apps/fieldnetMobile";

#define kApiStatusOk  0
#define kApiStatusUpdateAvailable  1
#define kApiStatusUnsupported  2

@implementation FN3ApiStatus

static id _instance = nil;

+ (void)initialize {
    if (self == [FN3ApiStatus class]) {
        _instance = [[self alloc] init];
    }
}

+ (FN3ApiStatus *)instance {
    return _instance;
}

- (void)dealloc
{
    message = nil;
}

- (void)prompt:(NSInteger)apiStatus
{
    if (apiStatus != 2) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update Available", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Update later", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Update now", nil), nil];
            [alert show];
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    } else {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update Available", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Update now", nil), nil];
            [alert show];
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }
}

- (BOOL)isActive
{
    if (isSuccess) {
        return status != kApiStatusUnsupported;
    } else {
        DTCredentials *credentials = [DTCredentials instance];
        NSString *username, *password;
        if (credentials) {
            username = credentials.username;
            password = credentials.password;
        }
        
        [DTConnection validateUsername:username password:password];
        
        return status != kApiStatusUnsupported;
    }
}

- (void)setResponse:(id)response
{
    isSuccess = YES;
    
    status = [[response objectForKey:@"clientStatus"] integerValue];
    message = [response objectForKey:@"clientStatusMessage"];
    
    if (status != kApiStatusOk) {
        [self prompt:status];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:APP_ITUNES_LINK];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
