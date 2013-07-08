//
//  NSURL+DTURL.h
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (DTURL)

- (NSURL *)urlByAppendingQuery:(NSDictionary *)params;

- (NSURL *)signedURLForUsername:(NSString *)username 
                     signingKey:(NSString *)signingKey 
                       postData:(NSDictionary *)postData;

@end
