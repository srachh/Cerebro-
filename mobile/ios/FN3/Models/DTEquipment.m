//
//  DTEquipment.m
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipment.h"
#import "DTEquipmentGroup.h"
#import "DTEquipmentDataField.h"
#import "DTEquipmentAccessoryField.h"

#import "NSDate+DTDate.h"
#import "NSDictionary+DTDictionary.h"

#import <CoreLocation/CoreLocation.h>


NSString * const DTEquipmentUpdate = @"DTEquipmentUpdate";
NSString * const DTEquipmentDetailUpdate = @"DTEquipmentDetailUpdate";
NSString * const DTEquipmentDelete = @"DTEquipmentDelete";

@interface DTEquipment()

@property (strong) CLLocation *location;
@end


@implementation DTEquipment
@synthesize location;

@dynamic identifier;
@dynamic lastUpdated;
@dynamic latitude, longitude;
@dynamic driver;
@dynamic title, subtitle;
@dynamic commStatusDescription, statusSummary;
@dynamic color;
@dynamic group, alerts, dataFields, accessoryFields;

+ (DTEquipment *)createEquipment:(NSString *)type inContext:(NSManagedObjectContext *)context;
{
    return [NSEntityDescription insertNewObjectForEntityForName:type
                                         inManagedObjectContext:context];
}

+ (DTEquipment *)equipment:(NSString *)type byId:(NSNumber *)identifier inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:type inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (DTEquipment *)equipmentWithId:(NSNumber *)identifier inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)equipmentInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" 
                                                           ascending:YES 
                                                            selector:@selector(caseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

- (CGSize)size
{
    return CGSizeMake(12, 12);
}

- (DTCommmStatus)commStatus
{
    if ([@"green" isEqualToString:self.commStatusDescription]) {
        return DTCommStatusGreen;
    } else if ([@"red" isEqualToString:self.commStatusDescription]) {
        return DTCommStatusRed;
    } else if ([@"yellow" isEqualToString:self.commStatusDescription]) {
        return DTCommStatusYellow;
    } else {
        return DTCommStatusGray;
    }
}

- (BOOL)isOfType:(NSString *)type
{
    return [self.entity.name isEqualToString:type];
}

- (DTEquipmentDataField *)fieldWithName:(NSString *)name
{
    for (DTEquipmentDataField *field in self.dataFields) {
        if ([field.name isEqualToString:name]) {
            return field;
        }
    }
    return nil;
}

- (void)setDataField:(NSString *)name value:(NSString *)value uom:(NSString *)uom
{
    DTEquipmentDataField *field;
    for (DTEquipmentDataField *f in self.dataFields) {
        if ([f.name isEqualToString:name]) {
            field = f;
            break;
        }
    }
    
    if (!field) {
        field = [NSEntityDescription insertNewObjectForEntityForName:[[DTEquipmentDataField class] description] 
                                              inManagedObjectContext:self.managedObjectContext];
        field.equipment = self;
        field.name = name;
    }
    field.value = value;
    field.uom = uom;
}

- (void)setDataField:(NSString *)name fromDictionary:(NSDictionary *)dictionary
{
    id value = [dictionary objectForKey:@"value"];
    if (value == [NSNull null]) {
        value = nil;
    } else {
        value = [value description];
    }
    
    id uom = [dictionary objectForKey:@"uom"];
    if (uom == [NSNull null]) {
        uom = nil;
    }
    
    [self setDataField:name value:value uom:uom];
}

- (DTEquipmentAccessoryField *)accessoryFieldWithName:(NSString *)name
{
    for (DTEquipmentAccessoryField *field in self.accessoryFields) {
        if ([field.name isEqualToString:name]) {
            return field;
        }
    }
    return nil;
}

- (void)setAccessoryField:(NSString *)name value:(NSNumber *)value
{
    DTEquipmentAccessoryField *field;
    for (DTEquipmentAccessoryField *f in self.accessoryFields) {
        if ([f.name isEqualToString:name]) {
            field = f;
            break;
        }
    }
    
    if (!field) {
        field = [NSEntityDescription insertNewObjectForEntityForName:[[DTEquipmentAccessoryField class] description]
                                              inManagedObjectContext:self.managedObjectContext];
        field.equipment = self;
        field.name = name;
    }
    field.value = value;
}

- (void)setAccessoryField:(NSString *)name fromDictionary:(NSDictionary *)dictionary
{
    id value = [dictionary objectForKey:@"value"];
    if (value == [NSNull null]) {
        value = nil;//[NSNumber numberWithBool:NO];
    }
    
    [self setAccessoryField:name value:value];
}

- (void)parseGeneralData:(NSDictionary *)data
{
    data = [data dictionaryByRemovingNullVales];
    if ([data objectForKey:@"name"]) {
        self.title = [data objectForKey:@"name"];
    }
    self.subtitle = [data objectForKey:@"subtitle"];
    
    NSDictionary *d = [[data objectForKey:@"geographical"] dictionaryByRemovingNullVales];
    self.latitude = [d objectForKey:@"latitude"];
    self.longitude = [d objectForKey:@"longitude"];
}

- (void)parseGeneralDetailData:(NSDictionary *)data
{
    self.driver = [data objectForKey:@"driver"];
    if ([data objectForKey:@"updated"] != [NSNull null]) {
        self.lastUpdated = [NSDate dateFromParsingMessageString:[data objectForKey:@"updated"]];
    } else {
        self.lastUpdated = nil;
    }
    
    NSDictionary *d = [[data objectForKey:@"status"] dictionaryByRemovingNullVales];
    self.statusSummary = [d objectForKey:@"summary"];
    self.commStatusDescription = [d objectForKey:@"communication"];
    
    d = [[data objectForKey:@"geographical"] dictionaryByRemovingNullVales];
    self.latitude = [d objectForKey:@"latitude"];
    self.longitude = [d objectForKey:@"longitude"];
}

- (void)parseIconData:(NSDictionary *)iconData {}
- (void)parseDetailData:(NSDictionary *)data {}

@end
