//
//  NSData+DTData.m
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "NSData+DTData.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (DTData)

- (NSString *)base64Encode
{
    if ([self length] == 0) {
		return @"";
    }
    
    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL) {
		return nil;
    }
	NSUInteger length = 0;
    
	NSUInteger i = 0;
	while (i < [self length]) {
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length]) {
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
        }
        
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1) {
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		} else {
            characters[length++] = '=';
        }
        
		if (bufferLength > 2) {
			characters[length++] = encodingTable[buffer[2] & 0x3F];
        } else { 
            characters[length++] = '=';	
        }
	}
    
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSString *)hexString {
    NSMutableString *str = [NSMutableString stringWithCapacity:[self length]];
    const unsigned char *byte = [self bytes];
    const unsigned char *endByte = byte + [self length];
    for (; byte != endByte; ++byte) [str appendFormat:@"%02x", *byte];
    return str;
}

@end
