//
//  DTEquipmentDataField.h
//  FN3
//
//  Created by David Jablonski on 5/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTEquipment;

@interface DTEquipmentDataField : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uom;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) DTEquipment *equipment;

@property (nonatomic, readonly) NSNumber *numericValue;

@end
