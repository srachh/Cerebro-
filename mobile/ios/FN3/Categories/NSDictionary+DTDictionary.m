//
//  NSDictionary+DTDictionary.m
//  FN3
//
//  Created by David Jablonski on 3/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSDictionary+DTDictionary.h"
#import "NSString+DTString.h"

@implementation NSDictionary (DTDictionary)

- (NSDictionary *)dictionaryByRemovingNullVales
{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    for (id key in self) {
        id value = [self objectForKey:key];
        if (value != [NSNull null]) {
            [d setObject:value forKey:key];
        }
    }
    return d;
}

- (NSString *)urlEncodedString
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] init];
    for (id key in self) {
        [self addValue:[self objectForKey:key] withKey:key toQueryString:urlWithQuerystring];
    }
    return urlWithQuerystring;
}

- (void)addValue:(id)value withKey:(id)key toQueryString:(NSMutableString *)params
{
    if ([value isKindOfClass:[NSArray class]]) {
        key = [NSString stringWithFormat:@"%@[]", key];
        for (id v in value) {
            [self addValue:v withKey:key toQueryString:params];
        }
        
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        for (NSString *s in value) {
            key = [NSString stringWithFormat:@"%@[%@]", key, s];
            id v = [value objectForKey:s];
            [self addValue:v withKey:key toQueryString:params];
        }
    } else {
        NSString *keyString = [[key description] urlEncode];
        NSString *valueString = value == [NSNull null] ? @"" : [[value description] urlEncode];
        
        if (params.length > 0) {
            [params appendString:@"&"];
        }
        
        [params appendString:keyString];
        [params appendString:@"="];
        [params appendString:valueString];
    }
}

@end
