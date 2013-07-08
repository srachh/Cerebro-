//
//  DTAlert.h
//  FN3
//
//  Created by David Jablonski on 4/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


extern NSString * const DTAlertUpdate;
extern NSString * const DTEquipmentAlertStatusUpdate;


@class DTEquipment;

@interface DTAlert : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * viewed;
@property (nonatomic, retain) DTEquipment *equipment;

+ (DTAlert *)createAlertInContext:(NSManagedObjectContext *)context;

+ (DTAlert *)alertWithId:(NSNumber *)identifier 
               inContext:(NSManagedObjectContext *)context;

+ (NSArray *)alertsForEquipment:(NSSet *)equipment 
                      inContext:(NSManagedObjectContext *)context;

+ (NSArray *)alertsInContext:(NSManagedObjectContext *)context;

@end
