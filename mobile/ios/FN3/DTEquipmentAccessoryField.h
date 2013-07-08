//
//  DTEquipmentAccessoryField.h
//  FieldNET
//
//  Created by Loren Davelaar on 1/8/13.
//  Copyright (c) 2013 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTEquipment;

@interface DTEquipmentAccessoryField : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) DTEquipment *equipment;

@end
