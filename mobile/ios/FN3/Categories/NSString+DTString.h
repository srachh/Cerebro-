//
//  NSString+DTString.h
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnigRegexp.h"

@interface NSString (DTString)

/*
 * Returns true if the NSString contains only whitespace characters.
 */
- (BOOL)isBlank;

/*
 * Strips begining and trailing whitespace from the NSString.
 */
- (NSString *)strip;

- (NSData *)sha1;
- (NSData *)hmacWithKey:(NSString *)key;

- (NSString *)urlEncode;
- (NSString *)urlDecode;

/*
 * Replaces all occurences of the pattern with the replacement.
 */
- (NSString*) gsub:(NSString*)pattern with:(id)replacement;

/*
 * Replaces all occurences of the pattern with the value returned by the block.
 */
- (NSString*) gsub:(NSString*)pattern withBlock:(NSString* (^)(OnigResult*))replacement;

/*
 * Titleizes the NSString.
 *
 * Examples:
 *   MY UPPER CASE STRING  -> My Upper Case String
 *   my_underscored_string -> My Underscored String
 */
- (NSString *)titleize;

/*
 * Underscores the NSString.
 *
 * Examples:
 *   MyClassName  -> my_class_name
 *   TNTClassName -> tnt_class_name
 */
- (NSString *)underscore;

- (NSString *)camelize;
- (NSString *)camelizeFirstLetterInUppercase:(BOOL)firstLetterInUppercase;

@end
