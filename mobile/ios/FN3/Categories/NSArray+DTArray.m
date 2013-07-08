//
//  NSArray+DTArray.m
//  FN3
//
//  Created by David Jablonski on 4/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSArray+DTArray.h"

@implementation NSArray (DTArray)

- (id)inject:(id)initialValue block:(id (^)(id memo, id object))block
{
    id memo = initialValue;
    for (id object in self) {
        memo = block(memo, object);
    }
    return memo;
}

- (NSDictionary *)indexBy:(id (^)(id object))block
{
    return [self inject:[NSMutableDictionary dictionary] block:^(id dictionary, id object) {
        id key = block(object);
        [dictionary setObject:object forKey:key];
        return dictionary;
    }];
}

- (NSDictionary *)groupBy:(id (^)(id object))block
{
    return [self inject:[NSMutableDictionary dictionary] block:^(id dictionary, id object) {
        id key = block(object);
        NSMutableArray *values = [dictionary objectForKey:key];
        if (!values) {
            values = [[NSMutableArray alloc] init];
            [dictionary setObject:values forKey:key];
        }
        [values addObject:object];
        return dictionary;
    }];
}

- (NSArray *)collect:(id (^)(id object))block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        [result addObject:block(object)];
    }
    
    return result;
}

- (NSArray *)slicesOfLength:(NSInteger)length
{
    NSInteger numberOfSlices = ceil(self.count / (float) length);
    
    NSMutableArray *slices = [[NSMutableArray alloc] initWithCapacity:numberOfSlices];
    for (int i = 0; i < numberOfSlices; i++) {
        NSRange range = {
            .location = i * length,
            .length = length
        };
        if (range.location + range.length > self.count) {
            range.length = self.count - range.location;
        }
        
        [slices addObject:[self subarrayWithRange:range]];
    }
    
    return slices;
}

@end
