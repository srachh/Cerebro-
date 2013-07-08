//
//  DTTranslation.m
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTTranslation.h"

NSString * const DTTranslationsUpdate = @"DTTranslationsUpdate";

@implementation DTTranslation

@dynamic language;
@dynamic key;
@dynamic value;

+ (DTTranslation *)createTranslationInContext:(NSManagedObjectContext *)context
{
    return (DTTranslation *)[NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                                          inManagedObjectContext:context];
}

+ (DTTranslation *)translationForKey:(NSString *)key 
                            language:(NSString *)language 
                             context:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self description] 
                                   inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"language = %@ and key = %@", language, key]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        return array.count == 0 ? nil : [array objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSDictionary *)translationsForLanguage:(NSString *)language 
                                  context:(NSManagedObjectContext *)context 
                                keysArray:(NSArray *)keys
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription
                        entityForName:[self description] inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"language = %@ and key in %@", language, keys]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:array.count];
        
        // default all values to the keys
        for (NSString *key in keys) {
            [d setObject:key forKey:key];
        }
        
        for (DTTranslation *t in array) {
            [d setObject:t.value forKey:t.key];
        }
        return d;
    } else {
        @throw error;
    }
}

+ (NSString *)translationInContext:(NSManagedObjectContext *)context key:(NSString *)key
{
    DTTranslation *t = [self translationForKey:key language:[[NSLocale currentLocale] localeIdentifier] context:context];
    return t ? t.value : key;
}

+ (NSDictionary *)translationsInContext:(NSManagedObjectContext *)context 
                                   keys:(NSString *)keys,...
{
    NSMutableArray *keyParams = [[NSMutableArray alloc] init];
    if (keys) {
        [keyParams addObject:keys];
        
        va_list args;
        va_start(args, keys);
        NSString *key;
        while ((key = va_arg(args, NSString *))) {
            [keyParams addObject:key];
        }
        va_end(args);
    }
    
    return [self translationsForLanguage:[[NSLocale currentLocale] localeIdentifier]
                                 context:context 
                                    keysArray:keyParams];
}

+ (NSDictionary *)translationsForLanguage:(NSString *)language 
                                  context:(NSManagedObjectContext *)context 
                                     keys:(NSString *)keys,...
{
    NSMutableArray *queryParams = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableString *queryString = [[NSMutableString alloc] init];
    [queryString appendString:@"language = %@"];
    [queryParams addObject:language];
    
    NSMutableArray *keyParams = [[NSMutableArray alloc] init];
    if (keys) {
        [keyParams addObject:keys];
        
        va_list args;
        va_start(args, keys);
        NSString *key;
        while ((key = va_arg(args, NSString *))) {
            [keyParams addObject:key];
        }
        va_end(args);
        
        [queryString appendString:@" and key in %@"];
        [queryParams addObject:keyParams];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription
                        entityForName:[self description] inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:queryString argumentArray:queryParams]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:array.count];
        
        // default translations that weren't found to the key
        for (NSString *key in keyParams) {
            [d setObject:key forKey:key];
        }
        
        for (DTTranslation *t in array) {
            [d setObject:t.value forKey:t.key];
        }
        
        return d;
    } else {
        @throw error;
    }
}

+ (NSArray *)translationsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription
                        entityForName:[self description] inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        return array;
    } else {
        @throw error;
    }
}

@end
