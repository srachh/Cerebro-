//
//  DTTTranslationParser.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTTTranslationParser.h"

#import "DTPersistentStore.h"
#import "DTTranslation.h"

@implementation DTTTranslationParser

- (id)initWithResponse:(id)_response
{
    if (self = [super init]) {
        response = _response;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    
    for (NSString *key in response) {
        DTTranslation *translation = [DTTranslation translationForKey:key 
                                                             language:language
                                                              context:store.managedObjectContext];
        if (!translation) {
            translation = [DTTranslation createTranslationInContext:store.managedObjectContext];
            translation.language = language;
            translation.key = key;
        }
        id value = [response objectForKey:key];
        translation.value = value == [NSNull null] ? nil : value;
    }
    [store save];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@"lastTranslationUpdate"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTTranslationsUpdate 
                                                        object:self];
}

@end
