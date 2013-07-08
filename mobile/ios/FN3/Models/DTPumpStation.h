//
//  DTPump.h
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DTEquipment.h"
#import "DTPump.h"

@class DTGauge, DTEquipmentDataField;

@interface DTPumpStation : DTEquipment

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * statusDescription;
@property (nonatomic, retain) NSSet * pumps;
@property (nonatomic, retain) NSSet * gauges;

/*
 * This is the name of the field to show on the dashboard as the first value
 * in the first section -- eg, 'Water Level' or 'Inlet Pressure'
 */
@property (nonatomic, retain) NSString *dashboardFieldName;

@property (nonatomic, readonly) DTEquipmentDataField *pressure;
@property (nonatomic, readonly) DTEquipmentDataField *flow;
@property (nonatomic, readonly) DTEquipmentDataField *power;
@property (nonatomic, readonly) DTEquipmentDataField *inletPressure;
@property (nonatomic, readonly) DTEquipmentDataField *waterLevel;
@property (nonatomic, readonly) DTEquipmentDataField *currentDemand;
@property (nonatomic, readonly) DTEquipmentDataField *remainingCapacity;
@property (nonatomic, readonly) DTPumpState state;

- (DTPump *)pumpWithName:(NSString *)name;
- (DTPump *)pumpWithOrder:(NSInteger)order;

- (DTGauge *)pressureGauge;
- (DTGauge *)flowGauge;
- (DTGauge *)powerGauge;

@end


@interface DTPumpStation (CoreDataGeneratedAccessors)

- (void)addGaugesObject:(NSManagedObject *)value;
- (void)removeGaugesObject:(NSManagedObject *)value;
- (void)addGauges:(NSSet *)values;
- (void)removeGauges:(NSSet *)values;

- (void)addPumpsObject:(NSManagedObject *)value;
- (void)removePumpsObject:(NSManagedObject *)value;
- (void)addPumps:(NSSet *)values;
- (void)removePumps:(NSSet *)values;

@end

