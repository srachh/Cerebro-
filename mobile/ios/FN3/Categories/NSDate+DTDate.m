//
//  NSDate+DTDate.m
//  FN3
//
//  Created by David Jablonski on 3/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSDate+DTDate.h"

@implementation NSDate (DTDate)

+ (NSDate *)dateFromParsingMessageString:(NSString *)string
{
    static dispatch_once_t pred = 0;
    __strong static id messageDateFormatter = nil;
    dispatch_once(&pred, ^{
        messageDateFormatter = [[NSDateFormatter alloc] init];
        //[messageDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSZ"];
        [messageDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    });
    
    return [messageDateFormatter dateFromString:string];
}

- (NSString*) toFormattedString:(NSString*)format timeZone:(NSTimeZone *)tz {
    time_t unixTime = (time_t) [self timeIntervalSince1970] + [tz secondsFromGMT];
    struct tm timeStruct;
    gmtime_r(&unixTime, &timeStruct);
    
    char buffer[30];
    strftime(buffer, 30, [format cStringUsingEncoding:[NSString defaultCStringEncoding]], &timeStruct);
    NSString* output = [NSString stringWithCString:buffer encoding:[NSString defaultCStringEncoding]]; 
    return output;
}

- (NSString*) toFormattedString:(NSString*)format {
    time_t unixTime = (time_t) [self timeIntervalSince1970];
    struct tm timeStruct;
    localtime_r(&unixTime, &timeStruct);
    
    char buffer[30];
    strftime(buffer, 30, [format cStringUsingEncoding:[NSString defaultCStringEncoding]], &timeStruct);
    NSString* output = [NSString stringWithCString:buffer encoding:[NSString defaultCStringEncoding]]; 
    return output;
}

- (NSString*) toGMFormattedString:(NSString*)format
{
    time_t unixTime = (time_t) [self timeIntervalSince1970];
    struct tm timeStruct;
    gmtime_r(&unixTime, &timeStruct);
    
    char buffer[30];
    strftime(buffer, 30, [format cStringUsingEncoding:[NSString defaultCStringEncoding]], &timeStruct);
    NSString* output = [NSString stringWithCString:buffer encoding:[NSString defaultCStringEncoding]]; 
    return output;
}

@end
