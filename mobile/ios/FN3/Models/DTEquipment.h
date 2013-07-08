//
//  DTEquipment.h
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTEquipmentDataField, DTEquipmentAccessoryField;

extern NSString * const DTEquipmentUpdate;
extern NSString * const DTEquipmentDetailUpdate;
extern NSString * const DTEquipmentDelete;


enum {
    DTEquipmentDirectionStopped    = 0,
    DTEquipmentDirectionForward    = 1,
    DTEquipmentDirectionReverse    = 2
};
typedef NSUInteger DTEquipmentDirection;


enum {
    DTCommStatusGreen   = 0,
    DTCommStatusRed     = 1,
    DTCommStatusYellow  = 2,
    DTCommStatusGray    = 3
};
typedef NSUInteger DTCommmStatus;


@class DTEquipmentGroup;

@interface DTEquipment : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * lastUpdated;

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@property (nonatomic, retain) NSString * driver;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;

@property (nonatomic, readonly) DTCommmStatus commStatus;
@property (nonatomic, retain) NSString * commStatusDescription;
@property (nonatomic, retain) NSString * statusSummary;

@property (nonatomic, retain) NSString * color;

@property (nonatomic, retain) DTEquipmentGroup * group;
@property (nonatomic, retain) NSSet * alerts;
@property (nonatomic, retain) NSSet * dataFields;
@property (nonatomic, retain) NSSet * accessoryFields;

+ (DTEquipment *)createEquipment:(NSString *)type inContext:(NSManagedObjectContext *)context;
+ (DTEquipment *)equipment:(NSString *)type byId:(NSNumber *)identifier inContext:(NSManagedObjectContext *)context;
+ (DTEquipment *)equipmentWithId:(NSNumber *)identifier inContext:(NSManagedObjectContext *)context;
+ (NSArray *)equipmentInContext:(NSManagedObjectContext *)context;

- (BOOL)isOfType:(NSString *)type;

- (CGSize)size;

- (void)parseGeneralData:(NSDictionary *)data;
- (void)parseGeneralDetailData:(NSDictionary *)data;
- (void)parseIconData:(NSDictionary *)iconData;
- (void)parseDetailData:(NSDictionary *)data;

- (DTEquipmentDataField *)fieldWithName:(NSString *)name;
- (void)setDataField:(NSString *)name value:(NSString *)value uom:(NSString *)uom;
- (void)setDataField:(NSString *)name fromDictionary:(NSDictionary *)dictionary;

- (DTEquipmentAccessoryField *)accessoryFieldWithName:(NSString *)name;
- (void)setAccessoryField:(NSString *)name value:(NSNumber *)value;
- (void)setAccessoryField:(NSString *)name fromDictionary:(NSDictionary *)dictionary;

@end



@interface DTEquipment (CoreDataGeneratedAccessors)

- (void)addAlertsObject:(NSManagedObject *)value;
- (void)removeAlertsObject:(NSManagedObject *)value;
- (void)addAlerts:(NSSet *)values;
- (void)removeAlerts:(NSSet *)values;

- (void)addDataFieldsObject:(NSManagedObject *)value;
- (void)removeDataFieldsObject:(NSManagedObject *)value;
- (void)addDataFields:(NSSet *)values;
- (void)removeDataFields:(NSSet *)values;

- (void)addAccessoryFieldsObject:(NSManagedObject *)value;
- (void)removeAccessoryFieldsObject:(NSManagedObject *)value;
- (void)addAccessoryFields:(NSSet *)values;
- (void)removeAccessoryFields:(NSSet *)values;


@end

