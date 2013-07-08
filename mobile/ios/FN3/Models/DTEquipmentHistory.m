//
//  DTEquipmentHistory.m
//  FieldNET
//
//  Created by Loren Davelaar on 8/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentHistory.h"

#import "NSDate+DTDate.h"
#import "NSDictionary+DTDictionary.h"

#import <CoreLocation/CoreLocation.h>

@implementation DTEquipmentHistory
@dynamic eventId;
@dynamic date;
@dynamic statusSummary;
@dynamic duration;
@dynamic rate;
@dynamic rateUOM;
@dynamic rateDepth;
@dynamic rateDepthUOM;
@dynamic position;
@dynamic positionUOM;
@dynamic accessory1;
@dynamic accessory2;
@dynamic chemigation;
@dynamic planDescription;
@dynamic water;
@dynamic order;

+ (DTEquipmentHistory *)createEquipmentHistory:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"DTEquipmentHistory"
                                         inManagedObjectContext:context];
}

+ (DTEquipmentHistory *)equipmentHistoryWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"eventId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (id)findOneInContext:(NSManagedObjectContext *)context 
         withPredicate:(NSString *)predicate 
         argumentArray:(NSArray *)argArray
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description]
                                 inManagedObjectContext:context];
    
    if (predicate) {
        if (argArray.count > 0) {
            request.predicate = [NSPredicate predicateWithFormat:predicate argumentArray:argArray];
        } else {
            request.predicate = [NSPredicate predicateWithFormat:predicate];
        }
    }
    
    return [self findOneInContext:context fetchRequest:request];
}

+ (id)findOneInContext:(NSManagedObjectContext *)context 
          fetchRequest:(NSFetchRequest *)request
{
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)equipmentHistoryInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:context];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

+ (DTEquipmentHistory *)equipmentHistory
{
    return [[self alloc] init];
}

- (NSString *)durationDescription
{
    if ((!self.duration) || (self.duration.doubleValue == 0) ) {
        return @"- - -";
    }
    
//    NSInteger seconds = self.duration.intValue;
//    NSInteger days = floor(seconds / 86400);
//    NSInteger hours = floor((seconds - (days * 86400)) / 3600);
//    NSInteger mins  = floor((seconds - (days * 86400) - (hours * 3600)) / 60);
//    NSInteger secs = seconds - ((days * 86400) + (hours * 3600) + (mins * 60));
    
//    NSInteger days = floor(self.duration.doubleValue / 24);
//    NSNumber *hours = [NSNumber numberWithDouble:self.duration.doubleValue - (days * 24)] ;
    
    NSMutableString *description = [[NSMutableString alloc] init];
    
//    if (days > 0) {
//        [description appendString:[NSString stringWithFormat:@"%i ", days]];
//        [description appendString:NSLocalizedString(days > 1 ? @"days" : @"day", nil)];
//    }
//    
//    if (description.length > 0) {
//        [description appendString:@" "];
//    }
//    
//    [description appendString:[NSString stringWithFormat:@"%.1f ", hours.doubleValue]];
    
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
//    if (mins > 0) {
//        if (description.length > 0) {
//            [description appendString:@" "];
//        }
//        
//        [description appendString:[NSString stringWithFormat:@"%i ", mins]];
//        [description appendString:NSLocalizedString(@"min", nil)];
//    }
//    if (secs > 0) {
//        if (description.length > 0) {
//            [description appendString:@" "];
//        }
//        
//        [description appendString:[NSString stringWithFormat:@"%i ", secs]];
//        [description appendString:NSLocalizedString(@"s", nil)];
//    }
    
    return description;
}

- (NSString *)rateDisplay
{
    if (self.rate) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumIntegerDigits = 3;
        formatter.maximumFractionDigits = 1;
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:self.rate], self.rateUOM];
    } else {
        return @"";
    }

}

- (NSString *)rateDepthDisplay
{
    if (self.rateDepth) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumIntegerDigits = 3;
        formatter.maximumFractionDigits = 2;
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:self.rateDepth], self.rateDepthUOM];
    } else {
        return @"";
    }
}

- (NSString *)positionDisplay
{
    if (self.position) {
        return [NSString stringWithFormat:@"%@\u00B0", self.position];
    } else {
        return @"";
    }
}

- (NSString *)accessoryDisplay
{
    NSMutableString *rtn = [[NSMutableString alloc] init];
    BOOL hasEntry = NO;
    
    if (self.accessory1) {
        [rtn appendString:self.accessory1];
        hasEntry = YES;
    }
    
    if (self.accessory2) {
        if (hasEntry) {
            [rtn appendString:@", "];
        } else {
            hasEntry = YES;
        }
        [rtn appendString:self.accessory2];
    }
    
    if (self.chemigation) {
        if (hasEntry) {
            [rtn appendString:@", "];
        } else {
            
            hasEntry = YES;
        }
        [rtn appendString:self.chemigation];
    }
    
    return rtn;
}

- (NSString *)waterDescription
{
    if (self.water) {
        return NSLocalizedString(@"On", nil);
    } else {
        return @"";
    }
    
}

- (void)parseData:(NSDictionary *)data
{
    data = [data dictionaryByRemovingNullVales];
    
    NSNumber *evtId = [data objectForKey:@"id"];
    self.eventId = [[NSNumber alloc] initWithInt:evtId.intValue];
    
    if ([data objectForKey:@"timestamp"]) {
        self.date = [NSDate dateFromParsingMessageString:[data objectForKey:@"timestamp"]];
    }
    else {
        self.date = nil;
    }
    
    self.statusSummary = [data objectForKey:@"status"];
    
    self.duration = [data objectForKey:@"duration"];
    
    NSDictionary *d = [[data objectForKey:@"rate"] dictionaryByRemovingNullVales];
    self.rate = [d objectForKey:@"value"];
    self.rateUOM = [d objectForKey:@"uom"];
    
    d = [[data objectForKey:@"depth"] dictionaryByRemovingNullVales];
    self.rateDepth = [d objectForKey:@"value"];
    self.rateDepthUOM = [d objectForKey:@"uom"];
    
    d = [[data objectForKey:@"position"] dictionaryByRemovingNullVales];
    self.position = [d objectForKey:@"value"];
    self.positionUOM = [d objectForKey:@"uom"];
    
    self.accessory1 = [data objectForKey:@"acc1"];
    self.accessory2 = [data objectForKey:@"acc2"];
    self.chemigation = [data objectForKey:@"chem"];
    self.planDescription = [data objectForKey:@"plan"];
    self.water = [data objectForKey:@"water"];
}



@end
