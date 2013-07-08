//
//  DTResponse.h
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTResponse : NSObject {
    NSInteger statusCode;
    BOOL isSuccess;
    id data;
    NSArray *errors;
}

@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) BOOL isSuccess;
@property (nonatomic, readonly) BOOL isAuthenticationError;
@property (nonatomic, readonly) id data;
@property (nonatomic, readonly) NSArray *errors;

- (id)initWithError:(NSString *)error responseCode:(NSInteger)responseCode;
- (id)initWithResponse:(NSHTTPURLResponse *)response error:(NSError *)error data:(NSData *)data;

@end
