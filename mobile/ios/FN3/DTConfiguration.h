//
//  DTConfiguration.h
//  FN3
//
//  Created by David Jablonski on 4/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DTEquipment.h"


extern NSString * const DTConfigurationUpdate;


@class DTConfigurationField, DTConfigurationDirection;

@interface DTConfiguration : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * displayTemperature;
@property (nonatomic, retain) NSNumber * displayVoltage;
@property (nonatomic, retain) NSSet *availableFields;
@property (nonatomic, retain) NSSet *availableDirections;
@property (nonatomic, retain) NSSet *plans;

@property (nonatomic) NSSet *availableFieldNames;
@property (nonatomic) NSSet *requiresWaterFieldNames;
@property (nonatomic) NSArray *availableDirectionNames;
@property (nonatomic) NSArray *availableDirectionValues;

+ (DTConfiguration *)configurationNamed:(NSString *)name 
                              inContext:(NSManagedObjectContext *)context;

+ (NSArray *)configurationsInContext:(NSManagedObjectContext *)context;

@end

@interface DTConfiguration (CoreDataGeneratedAccessors)

- (void)addAvailableFieldsObject:(DTConfigurationField *)value;
- (void)removeAvailableFieldsObject:(DTConfigurationField *)value;
- (void)addAvailableFields:(NSSet *)values;
- (void)removeAvailableFields:(NSSet *)values;

- (void)addAvailableDirectionsObject:(DTConfigurationDirection *)value;
- (void)removeAvailableDirectionsObject:(DTConfigurationDirection *)value;
- (void)addAvailableDirections:(NSSet *)values;
- (void)removeAvailableDirections:(NSSet *)values;

@end
