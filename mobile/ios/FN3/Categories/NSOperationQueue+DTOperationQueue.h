//
//  NSOperationQueue+DTOperationQueue.h
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

@protocol DTNetworkOperation;


@interface NSOperationQueue (DTOperationQueue)

+ (NSOperationQueue *)networkQueue;
+ (NSOperationQueue *)parserQueue;
+ (NSOperationQueue *)backgroundQueue;

- (void)addNetworkOperation:(NSOperation *)operation;
- (void)addNetworkOperationWithBlock:(void (^)(void))block;

@end
