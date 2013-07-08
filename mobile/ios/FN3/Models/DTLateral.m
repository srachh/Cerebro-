//
//  DTLateral.m
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTLateral.h"
#import "NSDictionary+DTDictionary.h"
#import "NSArray+DTArray.h"
#import "DTEquipmentDataField.h"
#import "DTEquipmentAccessoryField.h"

#import "DTConfiguration.h"
#import "DTPlan.h"

NSString * const DTLateralPressure = @"Pressure";
NSString * const DTLateralFlow = @"Flow1";
NSString * const DTLateralTemperature = @"Temperature";
NSString * const DTLateralVoltage = @"Voltage";

//Accessories
NSString * const DTLateralChemigation = @"Chemigation";
NSString * const DTLateralAccessoryOne = @"Accessory 1";
NSString * const DTLateralAccessoryTwo = @"Accessory 2";

@implementation DTLateral

@dynamic planId, planStepValue;
@dynamic rate, depthUom, depthConversionFactor;
@dynamic water, repeatServiceStop;

@dynamic length;
@dynamic directionOption, directionDescription;
@dynamic position, positionUom, servicePosition, servicePositionUom;
@dynamic trailStart, trailStop;
@dynamic duration;
@dynamic heightMeters, widthMeters;
@dynamic mapHeightMeters, mapWidthMeters;
@dynamic angle, pumpType;
@dynamic hoseStopPositions;

- (CGSize)size
{
    return CGSizeMake(self.mapWidthMeters.floatValue, self.mapHeightMeters.floatValue);
}

- (NSNumber *)depth
{
    return self.rate ? [self depthForRate:self.rate] : nil;
}

- (NSNumber *)depthForRate:(NSNumber *)rate
{
    CGFloat depth;
    if (rate.floatValue > 0) {
        depth = (self.depthConversionFactor.floatValue * 100.0) / rate.floatValue;
    } else {
        depth = 0;
    }
    
    return [NSNumber numberWithFloat:depth];
}

- (NSNumber *)rateForDepth:(NSNumber *)depth
{
    CGFloat rate;
    if (depth.floatValue > 0) {
        rate = (self.depthConversionFactor.floatValue / depth.floatValue) * 100.0;
        if (rate > 0 && rate < 1) {
            rate = 1;
        } else if (rate > 100) {
            rate = 100;
        }
    } else {
        rate = 0;
    }
    return [NSNumber numberWithFloat:rate];
}

- (DTEquipmentDataField *)pressure
{
    return [self fieldWithName:DTLateralPressure];
}

- (DTEquipmentDataField *)flow
{
    return [self fieldWithName:DTLateralFlow];
}

- (DTEquipmentDataField *)voltage
{
    return [self fieldWithName:DTLateralVoltage];
}

- (DTEquipmentDataField *)temperature
{
    return [self fieldWithName:DTLateralTemperature];
}

- (DTEquipmentAccessoryField *)accessoryOne
{
    return [self accessoryFieldWithName:DTLateralAccessoryOne];
}

- (DTEquipmentAccessoryField *)accessoryTwo
{
    return [self accessoryFieldWithName:DTLateralAccessoryTwo];
}

- (DTEquipmentAccessoryField *)chemigation
{
    return [self accessoryFieldWithName:DTLateralChemigation];
}

- (DTEquipmentDirection)direction
{
    if ([@"forward" isEqualToString:self.directionDescription]) {
        return DTEquipmentDirectionForward;
    } else if ([@"reverse" isEqualToString:self.directionDescription]) {
        return DTEquipmentDirectionReverse;
    } else {
        return DTEquipmentDirectionStopped;
    }
}

- (NSString *)durationDescription
{
    if ((!self.duration) || (self.duration.doubleValue == 0) ) {
        return @"- - -";
    }
    
//    NSInteger minutes = self.duration.integerValue;
//    NSInteger days = floor(minutes / (60 * 24));
//    minutes -= days * 60 * 24;
//    NSInteger hours = floor(minutes / 60);
//    minutes -= hours * 60;
    
    NSMutableString *description = [[NSMutableString alloc] init];
    
    [description appendString:[NSString stringWithFormat:@"%.1f ", self.duration.doubleValue]];
    [description appendString:NSLocalizedString(@"hrs", nil)];
    
//    if (days > 0) {
//        [description appendString:[NSString stringWithFormat:@"%i ", days]];
//        [description appendString:NSLocalizedString(days > 1 ? @"days" : @"day", nil)];
//    }
//    if (hours > 0) {
//        if (description.length > 0) {
//            [description appendString:@" "];
//        }
//        
//        [description appendString:[NSString stringWithFormat:@"%i ", hours]];
//        [description appendString:NSLocalizedString(hours > 1 ? @"hrs" : @"hr", nil)];
//    }
//    if (minutes > 0) {
//        if (description.length > 0) {
//            [description appendString:@" "];
//        }
//        
//        [description appendString:[NSString stringWithFormat:@"%i ", minutes]];
//        [description appendString:NSLocalizedString(@"min", nil)];
//    }
    
    return description;
}

- (NSArray *)hoseStopPositionsArray
{
    if (self.hoseStopPositions) {
        return [NSJSONSerialization JSONObjectWithData:[self.hoseStopPositions dataUsingEncoding:NSUTF8StringEncoding]
                                               options:0
                                                 error:nil];
    } else {
        return nil;
    }
}

- (Boolean)isPumpTypeEngine
{
    return (self.pumpType.intValue == 1);
}

- (void)parseIconData:(NSDictionary *)iconData
{
    iconData = [iconData dictionaryByRemovingNullVales];
    
    self.color = [iconData objectForKey:@"color"];
    //self.position = [iconData objectForKey:@"position"];
    self.length = [iconData objectForKey:@"length"];
    self.directionDescription = [iconData objectForKey:@"direction"];
    self.trailStart = [iconData objectForKey:@"trailStart"];
    self.trailStop = [iconData objectForKey:@"trailStop"];
    self.angle = [iconData objectForKey:@"angle"];
    //self.servicePosition = [iconData objectForKey:@"servicePosition"];
    NSDictionary *d = [[iconData objectForKey:@"position"] dictionaryByRemovingNullVales];
    self.position = [d objectForKey:@"value"];
    self.positionUom = [d objectForKey:@"uom"];
    
    d = [[iconData objectForKey:@"servicePosition"] dictionaryByRemovingNullVales];
    self.servicePosition = [d objectForKey:@"value"];
    self.servicePositionUom = [d objectForKey:@"uom"];

    self.heightMeters = [iconData objectForKey:@"heightMeters"];
    self.widthMeters = [iconData objectForKey:@"widthMeters"];
    self.mapHeightMeters = [iconData objectForKey:@"mapHeightMeters"];
    self.mapWidthMeters = [iconData objectForKey:@"mapWidthMeters"];
    
    if ([iconData objectForKey:@"hsPosition"]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:[iconData objectForKey:@"hsPosition"]
                                                       options:0
                                                         error:nil];
        self.hoseStopPositions = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        self.hoseStopPositions = nil;
    }
}

- (void)parseDetailData:(NSDictionary *)message
{
    message = [message dictionaryByRemovingNullVales];
    
    self.planId = [message objectForKey:@"planId"];
    self.planStepValue = [message objectForKey:@"planStep"];
    self.water = [message objectForKey:@"water"];
    self.rate = [message objectForKey:@"rate"];
    self.depthConversionFactor = [message objectForKey:@"conversion"];
    self.depthUom = [message objectForKey:@"depthSymbol"];
    self.repeatServiceStop = [message objectForKey:@"serviceStopRepeat"];
    self.directionOption = [message objectForKey:@"directionOption"];
    
    if ([message objectForKey:@"fullCircleTime"]) {
        self.duration = [NSNumber numberWithFloat:[[message objectForKey:@"fullCircleTime"] floatValue]];
    } else {
        self.duration = nil;
    }
    
    NSArray *data = [[message objectForKey:@"data"] collect:^id(NSDictionary *d) {
        return [d dictionaryByRemovingNullVales];
    }];
    NSDictionary *values = [data indexBy:^id(NSDictionary *o) {
        return [o objectForKey:@"name"];
    }];
    
    [self setDataField:DTLateralPressure fromDictionary:[values objectForKey:DTLateralPressure]];
    [self setDataField:DTLateralFlow fromDictionary:[values objectForKey:DTLateralFlow]];
    [self setDataField:DTLateralTemperature fromDictionary:[values objectForKey:DTLateralTemperature]];
    [self setDataField:DTLateralVoltage fromDictionary:[values objectForKey:DTLateralVoltage]];
    
    if ([message objectForKey:@"lateralPumpType"]) {
        self.pumpType = [message objectForKey:@"lateralPumpType"];
    } else {
        self.pumpType = 0;
    }
    
    //Parsing accessories
    NSMutableSet *foundIds = [NSMutableSet setWithCapacity:3];
    for (NSDictionary *d in [message objectForKey:@"accessories"]) {
        NSNumber *value = [d objectForKey:@"value"] == [NSNull null] ? nil : [d objectForKey:@"value"];
        [self setAccessoryField:[d objectForKey:@"name"] value:value];
        [foundIds addObject:[d objectForKey:@"name"]];
    }
    for (DTEquipmentAccessoryField *field in self.accessoryFields.allObjects) {
        if (![foundIds containsObject:field.name]) {
            [field.managedObjectContext deleteObject:field];
        }
    }
}


@end
