//
//  DTPivot.m
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPivot.h"
#import "NSDictionary+DTDictionary.h"
#import "NSArray+DTArray.h"
#import "DTEquipmentDataField.h"
#import "DTEquipmentAccessoryField.h"

#import "DTConfiguration.h"
#import "DTPlan.h"

NSString * const DTPivotPressure = @"Pressure";
NSString * const DTPivotFlow = @"Flow1";
NSString * const DTPivotTemperature = @"Temperature";
NSString * const DTPivotVoltage = @"Voltage";

//Accessories
NSString * const DTPivotChemigation = @"Chemigation";
NSString * const DTPivotAccessoryOne = @"Accessory 1";
NSString * const DTPivotAccessoryTwo = @"Accessory 2";


@implementation DTPivot

@dynamic planId, planStepValue;
@dynamic rate, depthUom, depthConversionFactor;
@dynamic water, repeatServiceStop;

@dynamic length;
@dynamic directionOption, directionDescription;
@dynamic position, positionUom, servicePosition, servicePositionUom;
@dynamic trailStart, trailStop;
@dynamic partial, partialStart, partialEnd;
@dynamic duration;

- (CGSize)size
{
    return CGSizeMake(self.length.floatValue * 2.0, self.length.floatValue * 2.0);
}

/*
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
 */

- (DTEquipmentDataField *)pressure
{
    return [self fieldWithName:DTPivotPressure];
}

- (DTEquipmentDataField *)flow
{
    return [self fieldWithName:DTPivotFlow];
}

- (DTEquipmentDataField *)voltage
{
    return [self fieldWithName:DTPivotVoltage];
}

- (DTEquipmentDataField *)temperature
{
    return [self fieldWithName:DTPivotTemperature];
}

- (DTEquipmentAccessoryField *)accessoryOne
{
    return [self accessoryFieldWithName:DTPivotAccessoryOne];
}

- (DTEquipmentAccessoryField *)accessoryTwo
{
    return [self accessoryFieldWithName:DTPivotAccessoryTwo];
}

- (DTEquipmentAccessoryField *)chemigation
{
    return [self accessoryFieldWithName:DTPivotChemigation];
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

- (void)parseIconData:(NSDictionary *)iconData
{
    iconData = [iconData dictionaryByRemovingNullVales];
    
    self.color = [iconData objectForKey:@"color"];
    self.directionDescription = [iconData objectForKey:@"direction"];
    self.trailStart = [iconData objectForKey:@"trailStart"];
    self.trailStop = [iconData objectForKey:@"trailAngle"];
    
    NSDictionary *d = [[iconData objectForKey:@"position"] dictionaryByRemovingNullVales];
    self.position = [d objectForKey:@"value"];
    self.positionUom = [d objectForKey:@"uom"];
    
    d = [[iconData objectForKey:@"servicePosition"] dictionaryByRemovingNullVales];
    self.servicePosition = [d objectForKey:@"value"];
    self.servicePositionUom = [d objectForKey:@"uom"];
    //self.position = [iconData objectForKey:@"position"];
    //self.servicePosition = [iconData objectForKey:@"servicePosition"];
    self.partial = [iconData objectForKey:@"partial"];
    self.partialStart = [iconData objectForKey:@"partialStart"];
    self.partialEnd = [iconData objectForKey:@"partialEnd"];
    self.length = [iconData objectForKey:@"length"];
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
    
    [self setDataField:DTPivotPressure fromDictionary:[values objectForKey:DTPivotPressure]];
    [self setDataField:DTPivotFlow fromDictionary:[values objectForKey:DTPivotFlow]];
    [self setDataField:DTPivotTemperature fromDictionary:[values objectForKey:DTPivotTemperature]];
    [self setDataField:DTPivotVoltage fromDictionary:[values objectForKey:DTPivotVoltage]];
    
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
