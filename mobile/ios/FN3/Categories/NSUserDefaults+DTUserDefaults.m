//
//  NSUserDefaults+DTUserDefaults.m
//  FN3
//
//  Created by David Jablonski on 3/30/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSUserDefaults+DTUserDefaults.h"

@implementation NSUserDefaults (DTUserDefaults)

- (NSString *)deviceIdentifier
{
    static NSString *deviceIdKey = @"deviceIdentifier";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults stringForKey:deviceIdKey];
    if (!uuid) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
        //get the string representation of the UUID
        uuid = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        [defaults setObject:uuid forKey:deviceIdKey];
        [defaults synchronize];
    }
    return uuid;
}

@end
