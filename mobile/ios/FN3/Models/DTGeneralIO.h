//
//  DTGeneralIO.h
//  FN3
//
//  Created by David Jablonski on 4/18/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DTEquipment.h"

@class DTEquipmentDataField;


@interface DTGeneralIO : DTEquipment {
    UIImage *icon;
}

@property (nonatomic, retain) NSNumber *enabled;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, retain) NSSet * dataFields;
@property (nonatomic, readonly) UIImage *icon;

@end
