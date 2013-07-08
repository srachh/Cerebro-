//
//  DTEquipmentGroup.h
//  FN3
//
//  Created by David Jablonski on 5/24/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


extern NSString * const DTEquipmentGroupUpdate;

@class DTEquipment;

@interface DTEquipmentGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *equipment;

+ (DTEquipmentGroup *)createEquipmentGroupInContext:(NSManagedObjectContext *)context;
+ (NSArray *)equipmentGroupsInContext:(NSManagedObjectContext *)context;
+ (DTEquipmentGroup *)equipmentGroupWithId:(NSNumber *)identifier 
                                 inContext:(NSManagedObjectContext *)context;

- (BOOL)containsEquipment:(DTEquipment *)equipment;

@end

@interface DTEquipmentGroup (CoreDataGeneratedAccessors)

- (void)addEquipmentObject:(DTEquipment *)value;
- (void)removeEquipmentObject:(DTEquipment *)value;
- (void)addEquipment:(NSSet *)values;
- (void)removeEquipment:(NSSet *)values;

@end
