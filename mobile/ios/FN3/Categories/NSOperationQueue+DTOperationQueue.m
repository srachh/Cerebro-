//
//  NSOperationQueue+DTOperationQueue.m
//  FN3
//
//  Created by David Jablonski on 3/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTCredentials.h"
#import "DTConnection.h"
#import "DTAppDelegate.h"

///////////////////////////////////////////////////////
//
// simple class to control the network activity spinner
//
///////////////////////////////////////////////////////

@interface DTSpinnerController : NSObject {
    BOOL visible;
}
@end

@implementation DTSpinnerController
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    @synchronized (self) 
    {
        NSInteger new = [[change objectForKey:@"new"] intValue];
        
        BOOL activityIndicatorVisible;
        if (new > 0) {
            activityIndicatorVisible = YES;
        } else if (new == 0) {
            activityIndicatorVisible = NO;
        }
        
        if (activityIndicatorVisible != visible) {
            visible = activityIndicatorVisible;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:activityIndicatorVisible];
            }];
        }
    }
}
@end

///////////////////////////////////////////////////////

@implementation NSOperationQueue (DTOperationQueue)

+ (NSOperationQueue *)backgroundQueue
{
    static dispatch_once_t pred = 0;
    __strong static id _backgroundQueue = nil;
    dispatch_once(&pred, ^{
        _backgroundQueue = [[NSOperationQueue alloc] init];
        [_backgroundQueue setName:@"BackgroundQueue"];
    });
    return _backgroundQueue;
}

+ (NSOperationQueue *)networkQueue
{
    static dispatch_once_t pred = 0;
    __strong static id _networkQueue = nil;
    __strong static id _spinnerController = nil;
    dispatch_once(&pred, ^{
        _spinnerController = [[DTSpinnerController alloc] init];
        
        _networkQueue = [[NSOperationQueue alloc] init];
        [_networkQueue setName:@"NetworkQueue"];
        [_networkQueue addObserver:_spinnerController
                        forKeyPath:@"operationCount" 
                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                           context:NULL];
    });
    return _networkQueue;
}

+ (NSOperationQueue *)parserQueue
{
    static dispatch_once_t pred = 0;
    __strong static id _parserQueue = nil;
    dispatch_once(&pred, ^{
        _parserQueue = [[NSOperationQueue alloc] init];
        [_parserQueue setName:@"ParserQueue"];
        [_parserQueue setMaxConcurrentOperationCount:1];
    });
    return _parserQueue;
}

- (void)addNetworkOperation:(NSOperation *)operation
{
    if ([DTConnection canSendMessages] && [DTCredentials instance].isValid) {
        [self addOperation:operation];
    }
}

- (void)addNetworkOperationWithBlock:(void (^)(void))block
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
        block();
    }];
    [self addNetworkOperation:op];
}

@end
