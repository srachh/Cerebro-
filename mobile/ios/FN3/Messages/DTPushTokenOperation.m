//
//  DTPushTokenOperation.m
//  FN3
//
//  Created by David Jablonski on 6/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPushTokenOperation.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "NSData+DTData.h"
#import "NSUserDefaults+DTUserDefaults.h"

@implementation DTPushTokenOperation

- (id)initWithToken:(NSData *)_token
{
    if (self = [super init]) {
        token= _token;
    }
    return self;
}

- (void)main
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ios", @"deviceType", 
                            token ? [token base64Encode] : [NSNull null], @"pushToken", 
                            [userDefaults deviceIdentifier], @"deviceId", nil];
    
    [DTConnection postTo:FN3APIPushToken parameters:params];
}

@end
