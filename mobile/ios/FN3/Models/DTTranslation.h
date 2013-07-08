//
//  DTTranslation.h
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DTTranslationsUpdate;

@interface DTTranslation : NSManagedObject

+ (DTTranslation *)createTranslationInContext:(NSManagedObjectContext *)context;
+ (DTTranslation *)translationForKey:(NSString *)key 
                            language:(NSString *)language 
                             context:(NSManagedObjectContext *)context;

+ (NSDictionary *)translationsForLanguage:(NSString *)language 
                                  context:(NSManagedObjectContext *)context 
                                keysArray:(NSArray *)keys;

+ (NSDictionary *)translationsForLanguage:(NSString *)language 
                                  context:(NSManagedObjectContext *)context 
                                     keys:(NSString *)keys,...;

+ (NSDictionary *)translationsInContext:(NSManagedObjectContext *)context 
                                   keys:(NSString *)keys,...;

+ (NSString *)translationInContext:(NSManagedObjectContext *)context key:(NSString *)key;

+ (NSArray *)translationsInContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;

@end
