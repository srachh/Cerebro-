//
//  DTEquipmentRefreshOperation.m
//  FN3
//
//  Created by David Jablonski on 5/3/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentOperation.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTPersistentStore.h"
#import "DTEquipment.h"
#import "NSDate+DTDate.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTEquipmentDetailParser.h"
#import "DTAppDelegate.h"

@implementation DTEquipmentOperation

- (id)initWithEquipmentId:(NSNumber *)_equipmentId
{
    if (self = [super init]) {
        equipmentId = _equipmentId;
    }
    return self;
}

- (void)main
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:equipmentId
                                                       forKey:@"id"];
    
    // update the list data
    DTResponse *detailResponse = [DTConnection getTo:FN3APIEquipmentDetail parameters:params];
    if (!self.isCancelled && detailResponse.isSuccess) {
        if ([detailResponse.data count] == 0) {
            [[NSOperationQueue parserQueue] addOperationWithBlock:^(void){
                // equipment was deleted
                DTPersistentStore *store = [[DTPersistentStore alloc] init];
                DTEquipment *equipment = [DTEquipment equipmentWithId:equipmentId 
                                                            inContext:store.managedObjectContext];
                
                [store.managedObjectContext deleteObject:equipment];
                [store save];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentUpdate
                                                                    object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentDelete 
                                                                    object:[NSSet setWithObject:equipmentId]];
            }];
        } else {
            [[NSOperationQueue parserQueue] addOperation:[[DTEquipmentDetailParser alloc] initWithResponse:detailResponse.data]];
        }
    } else if (detailResponse.isAuthenticationError) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
        }];
        
    }
}

@end
