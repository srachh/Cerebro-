//
//  DTEquipmentGroup.m
//  FN3
//
//  Created by David Jablonski on 5/24/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentGroup.h"
#import "DTEquipment.h"


NSString * const DTEquipmentGroupUpdate = @"DTEquipmentGroupUpdate";


@implementation DTEquipmentGroup

@dynamic identifier;
@dynamic name;
@dynamic equipment;

+ (DTEquipmentGroup *)createEquipmentGroupInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

+ (NSArray *)equipmentGroupsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

+ (DTEquipmentGroup *)equipmentGroupWithId:(NSNumber *)identifier 
                                 inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

- (BOOL)containsEquipment:(DTEquipment *)equipment
{
    for (DTEquipment *e in self.equipment) {
        if ([equipment.identifier isEqualToNumber:e.identifier]) {
            return YES;
        }
    }
    return NO;
}

@end
