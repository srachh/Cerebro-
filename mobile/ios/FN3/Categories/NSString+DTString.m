//
//  NSString+DTString.m
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSString+DTString.h"

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (DTString)

- (BOOL)isBlank
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".*\\S+.*"];
    return ![predicate evaluateWithObject:self];
}

- (NSString *)strip
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSData *)sha1;
{
    const char *cstr = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
    return [[NSData alloc] initWithBytes:digest length:sizeof(digest)];
}

- (NSString *)urlEncode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%%",
                                                                                 kCFStringEncodingUTF8 );
}

- (NSString *)urlDecode {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)hmacWithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (NSString*) gsub:(NSString*)pattern with:(id)replacement {
    if ([replacement isKindOfClass:[NSString class]]) {
        return [self replaceAllByRegexp:pattern with:replacement];        
    } else if ([replacement isKindOfClass:[NSArray class]]) {
        __block int i = -1;
        return [self replaceAllByRegexp:pattern withBlock:^(OnigResult* obj) {
            return (NSString*)[replacement objectAtIndex:(++i)];
        }];        
    }
    return nil;
}

- (NSString*) gsub:(NSString*)pattern withBlock:(NSString* (^)(OnigResult*))replacement {
    return [self replaceAllByRegexp:pattern withBlock:replacement];
}

- (NSString *)titleize
{
    return [[self lowercaseString] gsub:@"\\b('?[a-z])" withBlock:^(OnigResult *result) {
        return [[result stringAt:[result count] - 1] uppercaseString];
    }];
}

- (NSString *)underscore
{
    NSString *string = [self gsub:@"([A-Z]+)([A-Z][a-z])" withBlock:^(OnigResult *result) {
        return (NSString *)[NSString stringWithFormat:@"%@_%@", [result stringAt:1], [result stringAt:2]];
    }];
    string = [string gsub:@"([a-z\\d])([A-Z])" withBlock:^(OnigResult *result) {
        return (NSString *)[NSString stringWithFormat:@"%@_%@", [result stringAt:1], [result stringAt:2]];
    }];
    return [string lowercaseString];
}

- (NSString *)camelize
{
    return [self camelizeFirstLetterInUppercase:NO];
}

- (NSString *)camelizeFirstLetterInUppercase:(BOOL)firstLetterInUppercase
{
    NSString *string = [self gsub:@"(?:^|_)(.)" withBlock:^(OnigResult *result) {
        return [[result stringAt:1] uppercaseString];
    }];
    if (!firstLetterInUppercase) {
        string = [NSString stringWithFormat:@"%@%@", [[string substringToIndex:1] lowercaseString], [string substringFromIndex:1]];
    }
    return string;
}

@end
