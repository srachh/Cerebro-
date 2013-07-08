//
//  DTAlertsParser.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAlertsParser.h"

#import "DTPersistentStore.h"
#import "DTAlert.h"
#import "DTEquipment.h"
#import "NSDate+DTDate.h"

@implementation DTAlertsParser

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
    NSMutableArray *foundIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *fields in response) {
        if (self.isCancelled) {
            return;
        }
        
        DTEquipment *equipment = [DTEquipment equipmentWithId:[fields objectForKey:@"DeviceId"]
                                                    inContext:store.managedObjectContext];
        if (equipment) {
            NSNumber *identifier = [fields objectForKey:@"AlertId"];
            [foundIds addObject:identifier];
            
            DTAlert *alert = [DTAlert alertWithId:identifier inContext:store.managedObjectContext];
            if (!alert) {
                alert = [DTAlert createAlertInContext:store.managedObjectContext];
                alert.identifier = identifier;
            }
            
            alert.equipment = equipment;
            alert.message = [fields objectForKey:@"message"];
            alert.date = [NSDate dateFromParsingMessageString:[fields objectForKey:@"date"]];
        }
    }
    
    // remove any alerts not in the message
    for (DTAlert *alert in [DTAlert alertsInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        if (![foundIds containsObject:alert.identifier]) {
            [alert.equipment removeAlertsObject:alert];
            [store.managedObjectContext deleteObject:alert];
        }
    }
    
    [store save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTAlertUpdate object:nil];
}

@end
