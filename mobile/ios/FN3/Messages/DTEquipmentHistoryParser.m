//
//  DTEquipmentHistoryParser.m
//  FieldNET
//
//  Created by Loren Davelaar on 8/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentHistoryParser.h"

#import "DTPersistentStore.h"
#import "DTEquipmentHistory.h"

#import "NSOperationQueue+DTOperationQueue.h"

@implementation DTEquipmentHistoryParser

- (id)initWithListResponse:(NSArray *)_listResponse startIndex:(NSInteger)_startIndex
{
    if (self = [super init]) {
        listResponse = _listResponse;
        startIndex = _startIndex;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    
    [self parseList:listResponse store:store];
}

- (void)parseList:(id)response store:(DTPersistentStore *) store
{
    NSArray *historyRecords = [response objectForKey:@"records"];
    for (NSInteger i = 0; i < historyRecords.count; i++) {
        if (self.isCancelled) {
            return;
        }
        NSDictionary *fields = [historyRecords objectAtIndex:i];
        
        NSNumber *eventId = [fields objectForKey:@"id"];
        NSNumber *order = [NSNumber numberWithInt:i + startIndex];
        
//        DTEquipmentHistory *equipmentHistory = [DTEquipmentHistory findOneInContext:store.managedObjectContext withPredicate:@"eventId == %@ and order == %@" argumentArray:[NSArray arrayWithObjects:eventId, order, nil]];
        
        DTEquipmentHistory *equipmentHistory = [DTEquipmentHistory findOneInContext:store.managedObjectContext withPredicate:@"order == %@" argumentArray:[NSArray arrayWithObjects: order, nil]];
        
        if (!equipmentHistory) {
            equipmentHistory = [DTEquipmentHistory createEquipmentHistory:store.managedObjectContext];
            equipmentHistory.eventId = [[NSNumber alloc] initWithInt:eventId.intValue];
        }
        
        [equipmentHistory parseData:fields];
        
        equipmentHistory.order = order;
        
    }
    
    [store save];
}

@end
