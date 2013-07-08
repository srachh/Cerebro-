//
//  DTPump.m
//  FN3
//
//  Created by David Jablonski on 4/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPump.h"
#import "DTPumpStation.h"


@implementation DTPump

@dynamic name, enabled, hoa, order;
@dynamic color, statusDescription;
@dynamic station;


+ (DTPump *)createPumpInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

- (DTPumpState)state
{
    if ([@"regulate" isEqualToString:self.statusDescription]) {
        return DTPumpStateRegulating;
    } else if ([@"locked" isEqualToString:self.statusDescription]) {
        return DTPumpStateLocked;
    } else if ([@"pressurizing" isEqualToString:self.statusDescription]) {
        return DTPumpStatePressurizing;
    } else {
        return DTPumpStateNormal;
    }
}

@end
