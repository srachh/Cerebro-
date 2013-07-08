//
//  DTConfigurationParser.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTConfigurationParser.h"
#import "DTPersistentStore.h"
#import "DTConfiguration.h"
#import "DTPlan.h"
#import "DTPlanStep.h"
#import "DTGPIOType.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTIconDataOperation.h"
#import "DTImageData.h"
#import "NSDictionary+DTDictionary.h"

@implementation DTConfigurationParser

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
    
    id drivers = [response objectForKey:@"drivers"];
    id gpioTypes = [response objectForKey:@"gpioTypes"];
    
    if (drivers) {
        for (NSString *configName in drivers) {
            if (self.isCancelled) {
                return;
            }
            
            NSDictionary *configFields = [[drivers objectForKey:configName] dictionaryByRemovingNullVales];
            
            DTConfiguration *config = [DTConfiguration configurationNamed:configName 
                                                                inContext:store.managedObjectContext];
            if (!config) {
                config = [NSEntityDescription insertNewObjectForEntityForName:[[DTConfiguration class] description] 
                                                       inManagedObjectContext:store.managedObjectContext];
                config.name = configName;
            }
            
            config.availableFieldNames = [NSSet setWithArray:[configFields objectForKey:@"options"]];
            config.availableDirectionNames = [configFields objectForKey:@"directionOptions"];
            
            NSMutableSet *foundIds = [[NSMutableSet alloc] init];
            for (NSDictionary *planFields in [configFields objectForKey:@"plans"]) {
                if (self.isCancelled) {
                    return;
                }
                
                NSNumber *identifier = [planFields objectForKey:@"id"];
                [foundIds addObject:identifier];
                
                DTPlan *plan = [DTPlan configuration:config planById:identifier];
                if (!plan) {
                    plan = [NSEntityDescription insertNewObjectForEntityForName:[[DTPlan class] description] 
                                                         inManagedObjectContext:store.managedObjectContext];
                    plan.identifier = identifier;
                    plan.configuration = config;
                }
                
                plan.name = [planFields objectForKey:@"name"];
                
                // delete and re-create the steps
                for (DTPlanStep *step in plan.steps.allObjects) {
                    [plan removeStepsObject:step];
                    [step.managedObjectContext deleteObject:step];
                }
                
                id steps = [planFields objectForKey:@"stepsDef"];
                if (steps != [NSNull null]) {
                    for (NSInteger i = 0; i < [steps count]; i++) {
                        NSDictionary *stepFields = [[steps objectAtIndex:i] dictionaryByRemovingNullVales];
                        DTPlanStep *step = [NSEntityDescription insertNewObjectForEntityForName:[[DTPlanStep class] description]
                                                                         inManagedObjectContext:plan.managedObjectContext];
                        step.name = [stepFields objectForKey:@"label"];
                        step.value = [stepFields objectForKey:@"value"];
                        step.order = [NSNumber numberWithInt:i];
                        [plan addStepsObject:step];
                    }
                }
                
                id iconPath = [planFields objectForKey:@"icon"];
                plan.iconPath = iconPath == [NSNull null] ? nil : iconPath;
                
                plan.editableFieldNames = [NSSet setWithArray:[planFields objectForKey:@"options"]];
                
            }
            
            // remove any plans that no longer exist
            for (DTPlan *plan in config.plans) {
                if (self.isCancelled) {
                    return;
                }
                
                if (![foundIds containsObject:plan.identifier]) {
                    [store.managedObjectContext deleteObject:plan];
                }
            }
            
            // parse out the optionRules section
            NSMutableSet *requiresWaterFieldNames = [[NSMutableSet alloc] init];
            NSDictionary *optionRules = [configFields objectForKey:@"optionRules"];
            for (NSString *name in optionRules) {
                NSDictionary *rule = [optionRules objectForKey:name];
                if ([[rule objectForKey:@"requiresWater"] boolValue]) {
                    [requiresWaterFieldNames addObject:name];
                }
            }
            
            [config setRequiresWaterFieldNames:requiresWaterFieldNames];
            
//            id optionRules = [configFields objectForKey:@"optionRules"];
//            if (optionRules) {
//                
//                
//                
//                id optionField = [optionRules objectForKey:@"chemicalCheckbox"];
//                NSNumber *testNumber;
//                if (optionField != nil) {
//                    testNumber = [optionField objectForKey:@"requiresWater"];
//                    if (testNumber.intValue == 1) {
//                        [requiresWaterFieldNames addObject:@"chemicalCheckbox"];
//                    }
//                }
//                optionField = [optionRules objectForKey:@"acc1Checkbox"];
//                if (optionField != nil) {
//                    testNumber = [optionField objectForKey:@"requiresWater"];
//                    if (testNumber.intValue == 1) {
//                        [requiresWaterFieldNames addObject:@"acc1Checkbox"];
//                    }
//                }
//                optionField = [optionRules objectForKey:@"acc2Checkbox"];
//                if (optionField != nil) {
//                    testNumber = [optionField objectForKey:@"requiresWater"];
//                    if (testNumber.intValue == 1) {
//                        [requiresWaterFieldNames addObject:@"acc2Checkbox"];
//                    }
//                }
//                
//                [config setRequiresWaterFieldNames:requiresWaterFieldNames];
//            }
            
            // parse out the dataRules section
            id dataRules = [configFields objectForKey:@"dataRules"];
            
            id displayTemperature = [dataRules objectForKey:@"displayTemperature"];
            if (displayTemperature != nil) {
                config.displayTemperature = displayTemperature;
            } else {
                config.displayTemperature = NO;
            }
            
            id displayVoltage = [dataRules objectForKey:@"displayVoltage"];
            if (displayVoltage != nil) {
                config.displayVoltage = displayVoltage;
            } else {
                config.displayVoltage = NO;
            }
        }
        
        // delete any configs that no longer exist
        NSArray *validNames = [drivers allKeys];
        for (DTConfiguration *config in [DTConfiguration configurationsInContext:store.managedObjectContext]) {
            if (self.isCancelled) {
                return;
            }
            
            if (![validNames containsObject:config.name]) {
                [store.managedObjectContext deleteObject:config];
            }
        }
    }
    
    if (gpioTypes) {
        NSMutableSet *foundTypes = [[NSMutableSet alloc] init];
        
        for (NSString *typeCode in gpioTypes) {
            if (self.isCancelled) {
                return;
            }
            
            NSDictionary *typeFields = [[gpioTypes objectForKey:typeCode] dictionaryByRemovingNullVales];
            
            DTGPIOType *gpioType = [DTGPIOType gpioTypeByType:[typeFields objectForKey:@"type"] 
                                                                inContext:store.managedObjectContext];
            if (!gpioType) {
                gpioType = [NSEntityDescription insertNewObjectForEntityForName:[[DTGPIOType class] description] 
                                                       inManagedObjectContext:store.managedObjectContext];
                gpioType.type = [typeFields objectForKey:@"type"];
            }
            
            gpioType.typeDescription = [typeFields objectForKey:@"description"];
            gpioType.iconPath = [typeFields objectForKey:@"icon"];
            
            [foundTypes addObject:gpioType.type];
        }
        
        // delete any GPIO Types that no longer exist
        for (DTGPIOType *type in [DTGPIOType gpioTypesInContext:store.managedObjectContext]) {
            if (self.isCancelled) {
                return;
            }
            
            if (![foundTypes containsObject:type.type]) {
                [store.managedObjectContext deleteObject:type];
            }
        }
    }
    
    [store save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTConfigurationUpdate object:nil];
    
    [self getMissingIconsInStore:store];
    [self getMissingGPIOIconsInStore:store];
}

- (void)getMissingIconsInStore:(DTPersistentStore *)store
{
    NSMutableSet *missingIcons = [[NSMutableSet alloc] init];
    for (DTPlan *plan in [DTPlan plansInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        if (plan.iconPath) {
            DTImageData *imageData = [DTImageData imageDataForPath:plan.iconPath 
                                                         inContext:store.managedObjectContext];
            if (!imageData) {
                [missingIcons addObject:plan.iconPath];
            }
        }
    }
    
    if (!self.isCancelled && missingIcons.count > 0) {
        NSNotification *notification = [NSNotification notificationWithName:DTConfigurationUpdate object:nil];
        [[NSOperationQueue networkQueue] addOperation:[[DTIconDataOperation alloc] initWithImagePaths:missingIcons
                                                                                         notification:notification]];
    }
}

- (void)getMissingGPIOIconsInStore:(DTPersistentStore *)store
{
    NSMutableSet *missingIcons = [[NSMutableSet alloc] init];
    for (DTGPIOType *gpioType in [DTGPIOType gpioTypesInContext:store.managedObjectContext]) {
        if (self.isCancelled) {
            return;
        }
        
        if (gpioType.iconPath) {
            DTImageData *imageData = [DTImageData imageDataForPath:gpioType.iconPath 
                                                         inContext:store.managedObjectContext];
            if (!imageData) {
                [missingIcons addObject:gpioType.iconPath];
            }
        }
    }
    
    if (!self.isCancelled && missingIcons.count > 0) {
        NSNotification *notification = [NSNotification notificationWithName:DTConfigurationUpdate object:nil];
        [[NSOperationQueue networkQueue] addOperation:[[DTIconDataOperation alloc] initWithImagePaths:missingIcons
                                                                                         notification:notification]];
    }
}


@end
