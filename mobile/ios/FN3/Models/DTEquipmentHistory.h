//
//  DTEquipmentHistory.h
//  FieldNET
//
//  Created by Loren Davelaar on 8/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DTEquipmentHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * statusSummary;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * rateUOM;
@property (nonatomic, retain) NSNumber * rateDepth;
@property (nonatomic, retain) NSString * rateDepthUOM;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * positionUOM;
@property (nonatomic, retain) NSString * accessory1;
@property (nonatomic, retain) NSString * accessory2;
@property (nonatomic, retain) NSString * chemigation;
@property (nonatomic, retain) NSString * planDescription;
@property (nonatomic, retain) NSNumber * water;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, readonly) NSString * durationDescription;
@property (nonatomic, readonly) NSString * rateDisplay;
@property (nonatomic, readonly) NSString * rateDepthDisplay;
@property (nonatomic, readonly) NSString * positionDisplay;
@property (nonatomic, readonly) NSString * accessoryDisplay;
@property (nonatomic, readonly) NSString * waterDescription;

+ (DTEquipmentHistory *)createEquipmentHistory:(NSManagedObjectContext *)context;

+ (DTEquipmentHistory *)equipmentHistoryWithId:(NSNumber *)eventeId inContext:(NSManagedObjectContext *)context;
+ (NSSet *)equipmentHistoryInContext:(NSManagedObjectContext *)context;
+ (id)findOneInContext:(NSManagedObjectContext *)context withPredicate:(NSString *)predicate argumentArray:(NSArray *)argArray;
+ (id)findOneInContext:(NSManagedObjectContext *)context 
          fetchRequest:(NSFetchRequest *)request;
+ (DTEquipmentHistory *)equipmentHistory;

- (void)parseData:(NSDictionary *)data;

@end
