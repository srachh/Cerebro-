//
//  HelpText.m
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTHelpText.h"
#import "DTPersistentStore.h"
#import "DTTranslation.h"
#import "NSString+DTString.h"

@implementation DTHelpText

@synthesize keys;

- (id)init
{
    if (self = [super init]) {
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"plist"];
        NSDictionary *help = [[NSDictionary alloc] initWithContentsOfFile:plist];
        sections = [help objectForKey:@"sections"];
        
        keys = [[NSMutableArray alloc] init];
        for (NSDictionary *section in sections) {
            [keys addObject:[section objectForKey:@"section"]];
            for (NSDictionary *item in [section objectForKey:@"items"]) {
                [keys addObject:[item objectForKey:@"item"]];
            }
        }
        
        DTPersistentStore *store = [[DTPersistentStore alloc] init];
        translations = [DTTranslation translationsForLanguage:[[NSLocale currentLocale] localeIdentifier]
                                                      context:store.managedObjectContext 
                                                    keysArray:keys];
    }
    return self;
}

- (id)initWithSections:(NSArray *)_sections keys:(NSMutableArray *)_keys translations:(NSDictionary *)_translations
{
    if (self = [super init]) {
        sections = _sections;
        keys = _keys;
        translations = _translations;
    }
    return self;
}

- (void)dealloc
{
    sections = keys = nil;
    translations = nil;
}

- (DTHelpText *)filter:(NSString *)filter
{
    if (!filter || [filter isBlank]) {
        return self;
    }
    
    NSMutableArray *matchedSections = [[NSMutableArray alloc] initWithCapacity:sections.count];
    for (NSDictionary *section in sections) {
        BOOL matchedKeys = NO;
        
        NSMutableDictionary *matchedSection = [[NSMutableDictionary alloc] init];
        [matchedSection setObject:[section objectForKey:@"section"] forKey:@"section"];
        
        if ([[self translationForKey:[section objectForKey:@"section"]] rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [matchedSection setObject:[section objectForKey:@"items"] forKey:@"items"];
            matchedKeys = YES;
         } else {
             [matchedSection setObject:[[NSMutableArray alloc] init] forKey:@"items"];
             for (NSDictionary *item in [section objectForKey:@"items"]) {
                 NSString *translatedText = [self translationForKey:[item objectForKey:@"item"]];
                 if ([translatedText rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                     [[matchedSection objectForKey:@"items"] addObject:item];
                     matchedKeys = YES;
                 }
             }
         }
        
        if (matchedKeys) {
            [matchedSections addObject:matchedSection];
        }
    }
    
    return [[DTHelpText alloc] initWithSections:matchedSections keys:keys translations:translations];
}

- (NSInteger)numberOfSections
{
    return sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex >= sections.count) {
        return 0;
    }
    
    NSDictionary *section = [sections objectAtIndex:sectionIndex];
    NSArray *items = [section objectForKey:@"items"];
    return items.count;
}

- (NSString *)translationForKey:(NSString *)key
{
    NSString *text = [translations objectForKey:key];
    return text ? text : key;
}

- (NSString *)textForSection:(NSInteger)sectionIndex
{
    NSDictionary *section = [sections objectAtIndex:sectionIndex];
    return [self translationForKey:[section objectForKey:@"section"]];
}

- (NSString *)textForIndex:(NSInteger)index inSection:(NSInteger)sectionIndex
{
    NSDictionary *section = [sections objectAtIndex:sectionIndex];
    NSArray *items = [section objectForKey:@"items"];
    NSDictionary *item = [items objectAtIndex:index];
    return [self translationForKey:[item objectForKey:@"item"]];
}

- (NSString *)iconForIndex:(NSInteger)index inSection:(NSInteger)sectionIndex
{
    NSDictionary *section = [sections objectAtIndex:sectionIndex];
    NSArray *items = [section objectForKey:@"items"];
    NSDictionary *item = [items objectAtIndex:index];
    return [item objectForKey:@"icon"];
}

@end
