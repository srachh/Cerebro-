//
//  DTPlan.m
//  FN3
//
//  Created by David Jablonski on 4/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPlan.h"
#import "DTPlanField.h"
#import "DTPlanStep.h"
#import "DTConfiguration.h"
#import "DTImageData.h"


@implementation DTPlan

@dynamic identifier;
@dynamic name;
@dynamic steps;
@dynamic iconPath;
@dynamic configuration, editableFields;
@dynamic optionRules;

+ (DTPlan *)configuration:(DTConfiguration *)configuration 
                 planById:(NSNumber *)identifier 
{
    if (!identifier) {
        return nil;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"configuration = %@ and identifier = %@", configuration, identifier];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    
    NSError *error;
    NSArray *result = [configuration.managedObjectContext executeFetchRequest:request error:&error];
    
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (DTPlan *)configuration:(DTConfiguration *)config planName:(NSString *)planName
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"configuration = %@ and name = %@", config, planName];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    
    NSError *error;
    NSArray *result = [config.managedObjectContext executeFetchRequest:request error:&error];
    
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)plansInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

- (UIImage *)icon
{
    if (!icon) {
        if (self.iconPath) {
            DTImageData *imageData = [DTImageData imageDataForPath:self.iconPath 
                                                         inContext:self.managedObjectContext];
            if (imageData) {
                icon = [UIImage imageWithData:imageData.data];
            }
        }
    }
    return icon;
}

- (NSSet *)editableFieldNames
{
    NSMutableSet *names = [[NSMutableSet alloc] initWithCapacity:self.editableFields.count];
    for (DTPlanField *field in self.editableFields) {
        [names addObject:field.name];
    }
    return names;
}

- (NSSet *)optionRules
{
    NSMutableSet *names = [[NSMutableSet alloc] initWithCapacity:self.editableFields.count];
    for (DTPlanField *field in self.editableFields) {
        [names addObject:field.name];
    }
    return names;
}

- (void)setEditableFieldNames:(NSSet *)editableFieldNames
{
    [self removeEditableFields:self.editableFields];
    for (DTPlanField *field in self.editableFields) {
        [self.managedObjectContext deleteObject:field];
    }
    
    for (NSString *name in editableFieldNames) {
        DTPlanField *field = [DTPlanField createFieldInContext:self.managedObjectContext];
        field.name = name;
        [self addEditableFieldsObject:field];
    }
}

- (NSArray *)sortedSteps
{
    return [self.steps sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

- (DTPlanStep *)stepWithValue:(NSString *)value
{
    for (DTPlanStep *step in self.steps) {
        if ([step.value isEqualToString:value]) {
            return step;
        }
    }
    return nil;
}

@end
