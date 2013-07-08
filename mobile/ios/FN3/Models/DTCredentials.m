//
//  DTCredentials.m
//  FN3
//
//  Created by David Jablonski on 4/4/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTCredentials.h"
#import <Security/Security.h>


NSString * const _fn3KeychainItemIdentifier = @"com.digitec.FN3";


@implementation DTCredentials

@synthesize username, password, isStoredInKeychain, isValid;

+ (DTCredentials *)instance
{
    static dispatch_once_t pred = 0;
    __strong static id _appCredentials = nil;
    dispatch_once(&pred, ^{
        _appCredentials = [[self alloc] init];
    });
    return _appCredentials;
}

- (id)init
{
    if (self = [super init]) {
        [self loadFromKeychain];
    }
    return self;
}

- (void)dealloc
{
    username = password = nil;
}

- (void)loadFromKeychain
{
    NSDictionary *keychainItem = [self keychainItem];
    if (keychainItem) {
        username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
        
        NSData *passwordData = [self keychainValueForItem:keychainItem];
        password = [[NSString alloc] initWithBytes:[passwordData bytes] 
                                                      length:[passwordData length] 
                                                    encoding:NSUTF8StringEncoding];
        isStoredInKeychain = YES;
        self.isValid = YES;
    }
}

- (void)storeInKeychain
{
    NSDictionary *keychainItem = [self keychainItem];
    if (keychainItem) {
        NSMutableDictionary *updateItem = [[NSMutableDictionary alloc] initWithDictionary:keychainItem];
        [updateItem setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        NSMutableDictionary *tempCheck = [[NSMutableDictionary alloc] initWithDictionary:keychainItem];
        [tempCheck setObject:username forKey:(__bridge id)kSecAttrAccount];
        [tempCheck setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
        
        OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
        NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    } else {
        // create the item
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:_fn3KeychainItemIdentifier forKey:(__bridge id)kSecAttrGeneric];
        [item setObject:username forKey:(__bridge id)kSecAttrAccount];
        [item setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        [item setObject:@"" forKey:(__bridge id)kSecAttrLabel];
        [item setObject:@"" forKey:(__bridge id)kSecAttrDescription];
        [item setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        OSStatus result = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    }
    isStoredInKeychain = YES;
}

- (void)removeFromKeychain
{
    NSDictionary *keychainItem = [self keychainItem];
    if (keychainItem) {
        NSMutableDictionary *deleteItem = [[NSMutableDictionary alloc] initWithDictionary:keychainItem];
        [deleteItem setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)deleteItem);
        NSAssert( status == noErr || status == errSecItemNotFound, @"Problem deleting current dictionary." );
        
        isStoredInKeychain = NO;
    }
}

- (NSDictionary *)keychainItem {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:_fn3KeychainItemIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    CFTypeRef outRef = nil;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &outRef) == noErr) {
        return (__bridge_transfer NSDictionary *)outRef;
    } else {
        return nil;
    }
}

- (NSData *)keychainValueForItem:(NSDictionary *)keychainItem {
    // look up the password
    NSMutableDictionary *passwordLookup = [NSMutableDictionary dictionaryWithDictionary:keychainItem];
    [passwordLookup setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [passwordLookup setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    CFTypeRef outRef = nil;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)passwordLookup, &outRef) == noErr) {
        return (__bridge_transfer NSData *)outRef;
    } else {
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
        return nil;
    }
}

@end
