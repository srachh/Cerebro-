//
//  DTPushTokenOperation.h
//  FN3
//
//  Created by David Jablonski on 6/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTPushTokenOperation : NSOperation {
    NSData *token;
}

- (id)initWithToken:(NSData *)token;

@end
