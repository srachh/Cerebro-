//
//  NSURL+DTURL.m
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSURL+DTURL.h"
#import "NSDictionary+DTDictionary.h"
#import "NSString+DTString.h"
#import "NSDate+DTDate.h"
#import "NSData+DTData.h"
#import "NSArray+DTArray.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSURL (DTURL)

- (NSURL *)urlByAppendingQuery:(NSDictionary *)params
{
    NSMutableString *string = [[NSMutableString alloc] initWithString:self.absoluteString];
    if (!self.query || [self.query isBlank]) {
        [string appendString:@"?"];
    } else {
        [string appendString:@"&"];
    }
    [string appendString:[params urlEncodedString]];
    
    return [[NSURL alloc] initWithString:string];
}

- (NSURL *)signedURLForUsername:(NSString *)username signingKey:(NSString *)signingKey postData:(NSDictionary *)postData
{
    NSDate *signatureDate = [NSDate date];
    NSMutableDictionary *signatureParams = [[NSMutableDictionary alloc] init];
    
    [signatureParams setObject:[NSString stringWithFormat:@"%i", (int) [signatureDate timeIntervalSince1970]] forKey:@"timestamp"];
    [signatureParams setObject:username forKey:@"username"];
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObjectsFromArray:[[signatureParams urlEncodedString] componentsSeparatedByString:@"&"]];
    [params addObjectsFromArray:[self.query componentsSeparatedByString:@"&"]];
    if (postData) {
        [params addObjectsFromArray:[[postData urlEncodedString] componentsSeparatedByString:@"&"]];
    }
    NSDictionary *groupedParams = [params groupBy:^id(NSString *param) {
        return [[param componentsSeparatedByString:@"="] objectAtIndex:0];
    }];
    
    
    NSMutableString *stringToSign = [[NSMutableString alloc] init];
    [stringToSign appendString:self.path];
    for (NSString *key in [groupedParams.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        for (NSString *value in [groupedParams objectForKey:key]) {
            [stringToSign appendString:@"&"];
            [stringToSign appendString:[key urlDecode]];
            [stringToSign appendString:@"="];
            
            NSMutableArray *components = [NSMutableArray arrayWithArray:[value componentsSeparatedByString:@"="]];
            [components removeObjectAtIndex:0];
            [stringToSign appendString:[[components componentsJoinedByString:@"="] urlDecode]];
        }
    }
    
    NSString *signature = [[stringToSign hmacWithKey:signingKey] hexString];
    [signatureParams setObject:signature forKey:@"signature"];
    
    NSLog(@"\nsigned string: %@\n          sig: %@\n", stringToSign, signature);
    
    return [self urlByAppendingQuery:signatureParams];
}

@end
