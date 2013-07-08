//
//  NSArray+DTArray.h
//  FN3
//
//  Created by David Jablonski on 4/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DTArray)

/*
 * Returns the result of iterating through each item in this NSArray.  The
 * memo is the initialValue for the first item, and then the result of the
 * block for each subsequent item.  The value returned by calling the block
 * for the last item is returned.
 */
- (id)inject:(id)initialValue block:(id (^)(id memo, id object))block;

- (NSDictionary *)indexBy:(id (^)(id object))block;

/*
 * Group the elements in this NSArray by the result of passing each item
 * to the block.  The result is an NSDictionary of keys returned from the
 * block mapped to values of NSArrays.
 */
- (NSDictionary *)groupBy:(id (^)(id object))block;

/*
 * Retuns a new NSArray where each item in the new array is the result
 * of calling the block for each item in this NSArray.
 */
- (NSArray *)collect:(id (^)(id object))block;

- (NSArray *)slicesOfLength:(NSInteger)length;

@end
