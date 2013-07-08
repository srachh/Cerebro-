//
//  NSData+DTData.h
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DTData)

- (NSString *)base64Encode;

- (NSString *)hexString;

@end
