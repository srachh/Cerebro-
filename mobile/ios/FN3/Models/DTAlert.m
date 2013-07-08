//
//  DTAlert.m
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAlert.h"
#import "DTEquipment.h"


NSString * const DTAlertUpdate = @"DTAlertUpdate";
NSString * const DTEquipmentAlertStatusUpdate = @"DTEquipmentAlertStatusUpdate";


@implementation DTAlert

@dynamic date;
@dynamic identifier;
@dynamic message;
@dynamic viewed;
@dynamic equipment;

+ (DTAlert *)createAlertInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

+ (DTAlert *)alertWithId:(NSNumber *)identifier inContext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)alertsForEquipment:(NSSet *)equipment 
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"equipment in %@", equipment];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], 
                               [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO], 
                               nil];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

+ (NSArray *)alertsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], 
                               [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO], 
                               nil];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

@end
