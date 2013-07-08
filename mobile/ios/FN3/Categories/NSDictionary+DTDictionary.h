//
//  NSDictionary+DTDictionary.h
//  FN3
//
//  Created by David Jablonski on 3/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DTDictionary)

- (NSDictionary *)dictionaryByRemovingNullVales;
- (NSString *)urlEncodedString;

@end
