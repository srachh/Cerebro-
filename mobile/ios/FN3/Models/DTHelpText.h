//
//  HelpText.h
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTHelpText : NSObject {
    NSArray *sections;
    
    NSMutableArray *keys;
    NSDictionary *translations;
}

@property (nonatomic, readonly) NSArray *keys;
@property (nonatomic, readonly) NSInteger numberOfSections;

- (DTHelpText *)filter:(NSString *)filter;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (NSString *)translationForKey:(NSString *)key;
- (NSString *)textForSection:(NSInteger)section;
- (NSString *)textForIndex:(NSInteger)index inSection:(NSInteger)section;
- (NSString *)iconForIndex:(NSInteger)index inSection:(NSInteger)section;

@end
