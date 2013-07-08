//
//  DTCredentials.h
//  FN3
//
//  Created by David Jablonski on 4/4/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTCredentials : NSObject {
    NSString *username;
    NSString *password;
    BOOL isStoredInKeychain;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) BOOL isStoredInKeychain;
@property (nonatomic) BOOL isValid;

+ (DTCredentials *)instance;

- (void)loadFromKeychain;
- (void)storeInKeychain;
- (void)removeFromKeychain;

@end
