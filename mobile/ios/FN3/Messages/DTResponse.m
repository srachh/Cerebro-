//
//  DTResponse.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTResponse.h"

@implementation DTResponse 

@synthesize isSuccess, data, errors, statusCode;

- (id)initWithError:(NSString *)error responseCode:(NSInteger)responseCode
{
    if (self = [super init]) {
        isSuccess = NO;
        statusCode = responseCode;
        errors = [NSArray arrayWithObject:error];
    }
    return self;
}

- (id)initWithResponse:(NSHTTPURLResponse *)response error:(NSError *)error data:(NSData *)_data
{
    if (self = [super init]) {
        statusCode = 200;
        if (error) {
            if (error.domain == NSURLErrorDomain && (error.code == kCFURLErrorUserCancelledAuthentication || error.code == kCFURLErrorUserAuthenticationRequired)) {
                statusCode = 401;
            } else {
                statusCode = 500;
            }
        }
        
        NSString *contentType = [[response allHeaderFields] valueForKey:@"Content-Type"];
        if ([contentType hasPrefix:@"application/json"]) {
            NSString *s = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
            NSLog(@"got JSON %@", s);
            
            NSError *error;
            NSDictionary *wrapper = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
            
            isSuccess = statusCode == 200 && [[wrapper objectForKey:@"success"] boolValue];
            errors = [wrapper objectForKey:@"errors"];
            data = [wrapper objectForKey:@"data"];
            
        } else if ([contentType hasPrefix:@"text/"]) {
            NSLog(@"ignoring text response %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
        }
    }
    return self;
}

- (BOOL)isAuthenticationError
{
    return statusCode == 401;
}

@end
