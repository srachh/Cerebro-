//
//  DTEquipmentDetailParser.m
//  FN3
//
//  Created by David Jablonski on 5/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentDetailParser.h"
#import "DTPersistentStore.h"
#import "DTEquipment.h"

@implementation DTEquipmentDetailParser

- (id)initWithResponse:(id)_response
{
    if (self = [super init]) {
        response = _response;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    
    NSMutableSet *updatedIds = [[NSMutableSet alloc] initWithCapacity:[response count]];
    for (NSDictionary *fields in response) {
        if (self.isCancelled) {
            return;
        }
        
        DTEquipment *equipment = [DTEquipment equipmentWithId:[fields objectForKey:@"id"] 
                                                    inContext:store.managedObjectContext];
        
        [equipment parseGeneralData:fields];
        [equipment parseIconData:[fields objectForKey:@"icon"]];
        [equipment parseGeneralDetailData:fields];
        [equipment parseDetailData:fields];
        
        if (equipment.isUpdated) {
            [updatedIds addObject:equipment.identifier];
        }
    }
    
    if (updatedIds.count > 0) {
        [store save];
        [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentDetailUpdate 
                                                            object:updatedIds];
    }
}

@end
