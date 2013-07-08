//
//  DTPump.m
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPumpStation.h"
#import "DTPump.h"
#import "NSArray+DTArray.h"
#import "NSDictionary+DTDictionary.h"
#import "DTGauge.h"
#import "DTGaugeColor.h"
#import "DTGaugeMarker.h"
#import "DTEquipmentDataField.h"


NSString * const DTPumpStationPressure = @"System Pressure";
NSString * const DTPumpStationFlow = @"System Flow";
NSString * const DTPumpStationPower = @"Power";
NSString * const DTPumpStationWaterLevel = @"Water Level";
NSString * const DTPumpStationInletPressure = @"Inlet Pressure";
NSString * const DTPumpStationCurrentDemand = @"currentDemand";
NSString * const DTPumpStationRemainingCapacity = @"remainingCapacity";


@implementation DTPumpStation

@dynamic enabled, dashboardFieldName, statusDescription;
@dynamic pumps, gauges;

- (DTPump *)pumpWithName:(NSString *)name
{
    for (DTPump *pump in self.pumps) {
        if ([pump.name isEqualToString:name]) {
            return pump;
        }
    }
    return nil;
}

- (DTPump *)pumpWithOrder:(NSInteger)order
{
    for (DTPump *pump in self.pumps) {
        if ([pump.order intValue] == order) {
            return pump;
        }
    }
    return nil;    
}

- (DTGauge *)gaugeWithName:(NSString *)name
{
    for (DTGauge *gauge in self.gauges) {
        if ([name isEqualToString:gauge.title]) {
            return gauge;
        }
    }
    return nil;    
}

- (DTEquipmentDataField *)pressure
{
    return [self fieldWithName:DTPumpStationPressure];
}

- (DTGauge *)pressureGauge
{
    return [self gaugeWithName:DTPumpStationPressure];
}

- (DTEquipmentDataField *)flow
{
    return [self fieldWithName:DTPumpStationFlow];
}

- (DTGauge *)flowGauge
{
    return [self gaugeWithName:DTPumpStationFlow];
}

- (DTEquipmentDataField *)power
{
    return [self fieldWithName:DTPumpStationPower];
}

- (DTGauge *)powerGauge
{
    return [self gaugeWithName:DTPumpStationPower];
}

- (DTEquipmentDataField *)inletPressure
{
    return [self fieldWithName:DTPumpStationInletPressure];
}

- (DTEquipmentDataField *)waterLevel
{
    return [self fieldWithName:DTPumpStationWaterLevel];
}

- (DTEquipmentDataField *)currentDemand
{
    return [self fieldWithName:DTPumpStationCurrentDemand];
}

- (DTEquipmentDataField *)remainingCapacity
{
    return [self fieldWithName:DTPumpStationRemainingCapacity];
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

- (void)parseIconData:(NSDictionary *)iconData
{
    id color = [iconData objectForKey:@"color"];
    self.color = color == [NSNull null] ? nil : color;
    
    id state = [iconData objectForKey:@"state"];
    self.statusDescription = state == [NSNull null] ? nil : state;
}

- (void)parseDetailData:(NSDictionary *)message
{
    message = [message dictionaryByRemovingNullVales];
    
    NSArray *data = [[message objectForKey:@"data"] collect:^id(NSDictionary *d) {
        return [d dictionaryByRemovingNullVales];
    }];
    NSDictionary *values = [data indexBy:^id(NSDictionary *o) {
        return [o objectForKey:@"name"];
    }];
    
    [self setDataField:DTPumpStationPressure fromDictionary:[values objectForKey:DTPumpStationPressure]];
    [self setDataField:DTPumpStationFlow fromDictionary:[values objectForKey:DTPumpStationFlow]];
    [self setDataField:DTPumpStationPower fromDictionary:[values objectForKey:DTPumpStationPower]];
    [self setDataField:DTPumpStationInletPressure fromDictionary:[values objectForKey:DTPumpStationInletPressure]];
    [self setDataField:DTPumpStationWaterLevel fromDictionary:[values objectForKey:DTPumpStationWaterLevel]];
    [self setDataField:DTPumpStationCurrentDemand fromDictionary:[message objectForKey:DTPumpStationCurrentDemand]];
    [self setDataField:DTPumpStationRemainingCapacity fromDictionary:[message objectForKey:DTPumpStationRemainingCapacity]];
    
    self.enabled = [message objectForKey:@"enabled"];
    
    if ([[message objectForKey:@"renderWaterLevel"] boolValue]) {
        self.dashboardFieldName = DTPumpStationWaterLevel;
    } else if ([[message objectForKey:@"renderInletPressure"] boolValue]) {
        self.dashboardFieldName = DTPumpStationInletPressure;
    } else {
        self.dashboardFieldName = nil;
    }
    
    // parse out the pumps
    [self parsePumps:[message objectForKey:@"attachedPump"]];
    
    // parse out gauges
    [self parseGaugeFields:[message objectForKey:@"pressureData"] title:DTPumpStationPressure];
    [self parseGaugeFields:[message objectForKey:@"flowData"] title:DTPumpStationFlow];
    [self parseGaugeFields:[message objectForKey:@"powerData"] title:DTPumpStationPower];
}

- (void)parsePumps:(NSArray *)attachedPumps
{
    NSMutableArray *keepPumps = [[NSMutableArray alloc] initWithCapacity:attachedPumps.count];
    
    for (int i = 0; i < attachedPumps.count; i++) {
        NSDictionary *pumpFields = [attachedPumps objectAtIndex:i];
        pumpFields = [pumpFields dictionaryByRemovingNullVales];
        
        NSString *name = [pumpFields objectForKey:@"name"];
        
        DTPump *pump = [self pumpWithName:name];
        if (!pump) {
            pump = [DTPump createPumpInContext:self.managedObjectContext];
            pump.name = name;
            pump.station = self;
        }
        
        pump.enabled = [pumpFields objectForKey:@"enabled"];
        pump.hoa = [pumpFields objectForKey:@"hoa"];
        pump.color = [pumpFields objectForKey:@"color"];
        pump.statusDescription = [pumpFields objectForKey:@"state"];
        pump.order = [NSNumber numberWithInt:i];
        
        [keepPumps addObject:pump.name];
    }
    
    // delete any pumps not in the data
    for (DTPump *pump in self.pumps) {
        if (![keepPumps containsObject:pump.name]) {
            [self.managedObjectContext deleteObject:pump];
        }
    }
}

- (void)parseGaugeFields:(NSDictionary *)fields title:(NSString *)title
{
    DTGauge *oldGauge;
    for (DTGauge *g in self.gauges) {
        if ([g.title isEqualToString:title]) {
            oldGauge = g;
            break;
        }
    }
    if (oldGauge) {
        [self removeGaugesObject:oldGauge];
        [oldGauge.managedObjectContext deleteObject:oldGauge];
    }
    
    if (fields) {
        fields = [fields dictionaryByRemovingNullVales];
        
        DTGauge *gauge = [NSEntityDescription insertNewObjectForEntityForName:[[DTGauge class] description] 
                                                       inManagedObjectContext:self.managedObjectContext];
        gauge.title = title;
        gauge.min = [fields objectForKey:@"lowerLimit"];
        gauge.max = [fields objectForKey:@"upperLimit"];
        gauge.value = [fields objectForKey:@"value"];
        
        for (int i = 0; i < [[fields objectForKey:@"colors"] count]; i++) {
            NSDictionary *attrs = [[[fields objectForKey:@"colors"] objectAtIndex:i] dictionaryByRemovingNullVales];
            
            DTGaugeColor *color = [NSEntityDescription insertNewObjectForEntityForName:[[DTGaugeColor class] description] 
                                                                inManagedObjectContext:self.managedObjectContext];
            color.color = [attrs objectForKey:@"code"];
            
            if ([attrs objectForKey:@"minValue"]) {
                color.min = [NSNumber numberWithFloat:[[attrs objectForKey:@"minValue"] floatValue]];
            } else {
                color.min = gauge.min;
            }
            
            if ([attrs objectForKey:@"maxValue"]) {
                color.max = [NSNumber numberWithFloat:[[attrs objectForKey:@"maxValue"] floatValue]];
            } else {
                color.max = gauge.max;
            }
            
            if (color.max.floatValue < color.min.floatValue) {
                NSNumber *tmp = color.max;
                color.max = color.min;
                color.min = tmp;
            }
            
            color.order = [NSNumber numberWithInt:i];
            [gauge addColorsObject:color];
        }
        
        for (int i = 0; i < [[fields objectForKey:@"trendPoints"] count]; i++) {
            NSDictionary *attrs = [[[fields objectForKey:@"trendPoints"] objectAtIndex:i] dictionaryByRemovingNullVales];
            
            DTGaugeMarker *marker = [NSEntityDescription insertNewObjectForEntityForName:[[DTGaugeMarker class] description] 
                                                                  inManagedObjectContext:self.managedObjectContext];
            marker.order = [NSNumber numberWithInt:i];
            marker.fillColor = [attrs objectForKey:@"markerColor"];
            marker.value = [NSNumber numberWithFloat:[[attrs objectForKey:@"startValue"] floatValue]];
            marker.label = [attrs objectForKey:@"displayValue"];
            //marker.label = [[attrs objectForKey:@"displayValue"] description];
            
            [gauge addMarkersObject:marker];
        }
        
        [self addGaugesObject:gauge];
    }
}

@end
