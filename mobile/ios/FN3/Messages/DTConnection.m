//
//  FN3Connection.m
//  FN3
//
//  Created by David Jablonski on 4/2/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTConnection.h"
#import "NSDictionary+DTDictionary.h"
#import "NSUserDefaults+DTUserDefaults.h"
#import "FN3ApiStatus.h"
#import "Reachability.h"
#import "NSURL+DTURL.h"
#import "NSString+DTString.h"
#import "DTCredentials.h"
#import "DTResponse.h"
#import "DTAppDelegate.h"


NSString * const FN3APIStatus = @"api/status";
NSString * const FN3APISettings = @"user/profile";
NSString * const FN3APIChangePassword = @"user/password";
NSString * const FN3APIPushToken = @"user/push";

NSString * const FN3APIGroupList = @"equipment-group";
NSString * const FN3APIEquipmentList = @"equipment";
NSString * const FN3APIEquipmentDetail = @"equipment/get";
NSString * const FN3APIEquipmentPoll = @"equipment/poll";
NSString * const FN3APIEquipmentFeedback = @"equipment/feedback";
NSString * const FN3APIEquipmentOptions = @"equipment/options";
NSString * const FN3APIEquipmentHistory = @"equipment/history";

NSString * const FN3APITranslation = @"api/translation";
NSString * const FN3APIAlerts = @"alert";
NSString * const FN3APIConfiguration = @"equipment/configurations";

static NSString *_fn3ApiPathPrefix = @"api";
static NSString *_fn3ApiVersion = @"1.2";

@implementation DTConnection

+ (NSString *)getHost
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"api_url"];
}

+ (BOOL)canSendMessages
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    return [r currentReachabilityStatus] != NotReachable;
}

+ (NSData *)getDataForPath:(NSString *)path
{
    NSURL *url = [[NSURL alloc] initWithString:path relativeToURL:[NSURL URLWithString:[self getHost]]];
    return [[NSData alloc] initWithContentsOfURL:url];
}

+ (NSURL *)fn3URLFromPath:(NSString *)path
{
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@/%@", [self getHost], _fn3ApiPathPrefix, path]];
}

+ (DTResponse *)validateUsername:(NSString *)username password:(NSString *)password 
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [params setObject:@"ios" forKey:@"deviceType"];
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"?%@", [params urlEncodedString]] 
                                 relativeToURL:[self fn3URLFromPath:FN3APIStatus]];
    if (username && password) {
        url = [url signedURLForUsername:username signingKey:password postData:nil];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = [self headers];
    
    DTResponse *response = [self sendRequest:request checkApiStatus:NO checkCredentials:NO];
    if (response.isSuccess) {
        [[FN3ApiStatus instance] setResponse:response.data];
    }
    return response;
}

+ (DTResponse *)getTo:(NSString *)service parameters:(NSDictionary *)params 
{
    NSURL *url = [self fn3URLFromPath:service];
    if (params.count > 0) {
        url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"?%@", [params urlEncodedString]] 
                              relativeToURL:url];
    }
    
    DTCredentials *credentials = [DTCredentials instance];
    if (credentials.username && credentials.password) {
        url = [url signedURLForUsername:credentials.username signingKey:credentials.password postData:nil];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = [self headers];
    
    return [self sendRequest:request checkApiStatus:YES checkCredentials:YES];
}

+ (DTResponse *)postTo:(NSString *)service parameters:(NSDictionary *)params 
{
    NSURL *url = [self fn3URLFromPath:service];
    
    DTCredentials *credentials = [DTCredentials instance];
    if (credentials.username && credentials.password) {
        url = [url signedURLForUsername:credentials.username signingKey:credentials.password postData:params];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = [self headers];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [[params urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self sendRequest:request checkApiStatus:YES checkCredentials:YES];
}

+ (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithCapacity:3];
    //NSLog(@"Language: %@\n", [[[NSLocale currentLocale] localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"]);
    //NSLog(@"Preferred Language: %@\n", [[NSLocale preferredLanguages] objectAtIndex:0]);
    //NSLog(@"Region: %@\n", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]);
    
    // the application uses [NSLocale preferredLanguages] objectAtIndex:0] which can be different than [[NSLocale currentLocale] localeIdentifier]
    NSString *preferredLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *region = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *apiLanguage;
    
    if (region.length > 0) {
        apiLanguage = [NSString stringWithFormat:@"%@-%@", preferredLanguage, region];
    } else {
        apiLanguage = preferredLanguage;
    }
    
    //NSLog(@"API Language: %@", apiLanguage);

    [headers setObject:apiLanguage forKey:@"Accept-Language"];
    
//    [headers setObject:[[[NSLocale currentLocale] localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"]
//                forKey:@"Accept-Language"];
    [headers setObject:_fn3ApiVersion forKey:@"Accept-version"];
    return headers;
}

+ (DTResponse *)sendRequest:(NSMutableURLRequest *)request 
             checkApiStatus:(BOOL)checkApiStatus
           checkCredentials:(BOOL)checkCredentials
{
    if (![[self class] canSendMessages]) {
        return nil;
    } else if (checkApiStatus && ![[FN3ApiStatus instance] isActive]) {
        return nil;
    } else if (checkCredentials && ![DTCredentials instance].isValid) {
        return [[DTResponse alloc] initWithError:NSLocalizedString(@"Not authorized", nil) 
                                    responseCode:401];
    } else {
        request.timeoutInterval = 120;

        NSLog(@"\nURL: %@\n", request.URL);
        
        NSError *error;
        NSHTTPURLResponse *response;
        NSData *content = [NSURLConnection sendSynchronousRequest:request 
                                                returningResponse:&response 
                                                            error:&error];
        
        DTResponse *res =  [[DTResponse alloc] initWithResponse:response 
                                                          error:error 
                                                           data:content];
        if (res.isAuthenticationError) {
            [DTCredentials instance].isValid = NO;
        }
        
        return res;
    }
}

@end
