//
//  DTConfiguration.m
//  FN3
//
//  Created by David Jablonski on 4/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTConfiguration.h"
#import "DTConfigurationField.h"
#import "DTPlan.h"
#import "DTConfigurationDirection.h"
#import "NSArray+DTArray.h"

NSString * const DTConfigurationUpdate = @"DTConfigurationUpdate";


@implementation DTConfiguration

@dynamic name;
@dynamic displayTemperature;
@dynamic displayVoltage;
@dynamic availableFields;
@dynamic availableDirections;
@dynamic plans;

+ (DTConfiguration *)configurationNamed:(NSString *)name 
                              inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)configurationsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

- (NSSet *)availableFieldNames
{
    NSMutableSet *names = [[NSMutableSet alloc] initWithCapacity:self.availableFields.count];
    for (DTConfigurationField *field in self.availableFields) {
        [names addObject:field.name];
    }
    return names;
}

- (void)setAvailableFieldNames:(NSSet *)availableFieldNames
{
    for (DTConfigurationField *field in [self.availableFields allObjects]) {
        [self removeAvailableFieldsObject:field];
        [self.managedObjectContext deleteObject:field];
    }
    
    for (NSString *name in availableFieldNames) {
        DTConfigurationField *field = [DTConfigurationField createFieldInContext:self.managedObjectContext];
        field.name = name;
        [self addAvailableFieldsObject:field];
    }
}

- (NSSet *)requiresWaterFieldNames
{
    NSMutableSet *names = [[NSMutableSet alloc] init];
    for (DTConfigurationField *field in self.availableFields) {
        if (field.requiresWater.intValue == 1) {
            [names addObject:field.name];
        }
    }
    return names;
}

- (void)setRequiresWaterFieldNames:(NSSet *)requiresWaterFieldNames
{
    for (DTConfigurationField *field in [self.availableFields allObjects]) {
        field.requiresWater = [NSNumber numberWithBool:NO];
        for (NSString *name in requiresWaterFieldNames) {
            if ([name isEqual:[field name]]) {
                field.requiresWater = [NSNumber numberWithBool:YES];
            }
        }
    }
}

- (NSArray *)availableDirectionNames
{
    NSArray *sortedDirections = [[self.availableDirections allObjects] sortedArrayUsingComparator:^NSComparisonResult(DTConfigurationDirection *d1, DTConfigurationDirection *d2) {
        return [d1.order compare:d2.order];
    }];
    
    return [sortedDirections collect:^id(DTConfigurationDirection *dir) {
        return dir.name;
    }];
}
- (NSArray *)availableDirectionValues
{
    NSArray *sortedDirections = [[self.availableDirections allObjects] sortedArrayUsingComparator:^NSComparisonResult(DTConfigurationDirection *d1, DTConfigurationDirection *d2) {
        return [d1.order compare:d2.order];
    }];
    
    return [sortedDirections collect:^id(DTConfigurationDirection *dir) {
        return dir.value;
    }];
}

- (void)setAvailableDirectionNames:(NSArray *)availableDirectionNames
{
    for (DTConfigurationDirection *dir in [self.availableDirections allObjects]) {
        [self removeAvailableDirectionsObject:dir];
        [dir.managedObjectContext deleteObject:dir];
    }
    
    for (NSInteger i = 0; i < availableDirectionNames.count; i++) {
        DTConfigurationDirection *dir = [NSEntityDescription insertNewObjectForEntityForName:[[DTConfigurationDirection class] description] 
                                                                      inManagedObjectContext:self.managedObjectContext];
        dir.name = [[availableDirectionNames objectAtIndex:i] objectForKey:@"label"];
        dir.value = [[availableDirectionNames objectAtIndex:i] objectForKey:@"value"];
        dir.order = [NSNumber numberWithInt:i];
        [self addAvailableDirectionsObject:dir];
    }
}

@end
