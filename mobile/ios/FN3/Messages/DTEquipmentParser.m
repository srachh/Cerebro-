//
//  DTEquipmentParser.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentParser.h"

#import "DTPersistentStore.h"
#import "DTEquipment.h"
#import "DTEquipmentGroup.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTIconDataOperation.h"
#import "DTGeneralIO.h"
#import "DTImageData.h"

@implementation DTEquipmentParser

- (id)initWithGroupsResponse:(id)_groupsResponse listResponse:(id)_listResponse
{
    if (self = [super init]) {
        groupsResponse = _groupsResponse;
        listResponse = _listResponse;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    
    [self parseList:listResponse store:store];
    [self parseGroups:groupsResponse store:store];
}

- (void)parseGroups:(id)response store:(DTPersistentStore *)store
{
    NSMutableArray *foundGroupIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *groupFields in response) {
        if (self.isCancelled) {
            return;
        }
        
        NSNumber *identifier = [groupFields objectForKey:@"id"];
        [foundGroupIds addObject:identifier];
        
        DTEquipmentGroup *group = [DTEquipmentGroup equipmentGroupWithId:identifier
                                                               inContext:store.managedObjectContext];
        if (!group) {
            group = [DTEquipmentGroup createEquipmentGroupInContext:store.managedObjectContext];
            group.identifier = identifier;
        }
        group.name = [groupFields objectForKey:@"title"];
        
        NSMutableSet *foundEquipmentIds = [[NSMutableSet alloc] init];
        for (NSNumber *equipmentId in [groupFields objectForKey:@"equipment"]) {
            [foundEquipmentIds addObject:equipmentId];
            
            DTEquipment *equipment = [DTEquipment equipmentWithId:equipmentId inContext:store.managedObjectContext];
            if (equipment) {
                if (![group containsEquipment:equipment]) {
                    [group addEquipmentObject:equipment];
                }
            }
        }
        for (DTEquipment *equipment in [group.equipment allObjects]) {
            if (![foundEquipmentIds containsObject:equipment.identifier]) {
                [group removeEquipmentObject:equipment];
            }
        }
        
        // remove any groups that have no equipment
        if (group.equipment.count == 0) {
            [store.managedObjectContext deleteObject:group];
        }
    }
    
    for (DTEquipmentGroup *group in [DTEquipmentGroup equipmentGroupsInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        if (![foundGroupIds containsObject:group.identifier]) {
            [store.managedObjectContext deleteObject:group];
        }
    }
    
    [store save];
    [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentGroupUpdate 
                                                        object:nil];
}

- (void)parseList:(id)response store:(DTPersistentStore *)store
{
    NSMutableArray *foundEquipmentIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *fields in response) {
        if (self.isCancelled) {
            return;
        }
        
        NSString *type = [fields objectForKey:@"type"];
        if ([@"Pivot" isEqualToString:type]) {
            type = @"DTPivot";
        } else if ([@"Watertronics Pump Station" isEqualToString:type]) {
            type = @"DTPumpStation";
        } else if ([@"lateral" isEqualToString:type]) {
            type = @"DTLateral";
        } else {
            type = @"DTGeneralIO";
        }
        NSNumber *identifier = [fields objectForKey:@"id"];
        [foundEquipmentIds addObject:identifier];
        
        DTEquipment *equipment = [DTEquipment equipmentWithId:identifier 
                                                    inContext:store.managedObjectContext];
        
        if (equipment && ![equipment isOfType:type]) {
            // equipment type changed, delete it and re-create it
            [store.managedObjectContext deleteObject:equipment];
            equipment = nil;
        }
        
        if (!equipment) {
            equipment = [DTEquipment createEquipment:type inContext:store.managedObjectContext];
            equipment.identifier = identifier;
        }
        
        [equipment parseGeneralData:fields];
        [equipment parseIconData:[fields objectForKey:@"icon"]];
    }
    
    NSMutableSet *deletedEquipment = [[NSMutableSet alloc] init];
    for (DTEquipment *equipment in [DTEquipment equipmentInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        if (![foundEquipmentIds containsObject:equipment.identifier]) {
            [deletedEquipment addObject:equipment.identifier];
            [store.managedObjectContext deleteObject:equipment];
        }
    }
    [store save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentUpdate 
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentDelete
                                                        object:deletedEquipment];
    
    [self downloadMissingIconsInStore:store];
}

- (void)downloadMissingIconsInStore:(DTPersistentStore *)store
{
    NSMutableSet *missingIcons = [[NSMutableSet alloc] init];
    NSMutableSet *equipmentIds = [[NSMutableSet alloc] init];
    
    for (DTEquipment *equipment in [DTGeneralIO equipmentInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        DTGeneralIO *io = (DTGeneralIO *)equipment;
        
        if (io.iconPath) {
            DTImageData *imageData = [DTImageData imageDataForPath:io.iconPath 
                                                         inContext:store.managedObjectContext];
            if (!imageData) {
                [missingIcons addObject:io.iconPath];
                [equipmentIds addObject:io.identifier];
            }
        }
    }
    
    if (!self.isCancelled && missingIcons.count > 0) {
        NSNotification *notification = [NSNotification notificationWithName:DTEquipmentDetailUpdate 
                                                                     object:equipmentIds];
        [[NSOperationQueue networkQueue] addOperation:[[DTIconDataOperation alloc] initWithImagePaths:missingIcons 
                                                                                         notification:notification]];
    }
}

@end
