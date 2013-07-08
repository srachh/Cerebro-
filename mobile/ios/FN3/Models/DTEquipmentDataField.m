//
//  DTEquipmentDataField.m
//  FN3
//
//  Created by David Jablonski on 5/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentDataField.h"
#import "DTEquipment.h"


@implementation DTEquipmentDataField

@dynamic name;
@dynamic order;
@dynamic uom;
@dynamic value;
@dynamic equipment;

- (NSNumber *)numericValue
{
    if (self.value) {
        return [NSNumber numberWithFloat:self.value.floatValue];
    } else {
        return nil;
    }
}

@end
