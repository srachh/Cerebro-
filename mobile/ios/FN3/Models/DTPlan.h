//
//  DTPlan.h
//  FN3
//
//  Created by David Jablonski on 4/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class DTPlanField, DTConfiguration, DTPlanStep;


@interface DTPlan : NSManagedObject {
    UIImage *icon;
}

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, readonly) UIImage *icon;

@property (nonatomic, retain) DTConfiguration *configuration;
@property (nonatomic, retain) NSSet *editableFields;
@property (nonatomic, retain) NSSet *steps;


+ (DTPlan *)configuration:(DTConfiguration *)configuration
                 planById:(NSNumber *)identifier;

+ (DTPlan *)configuration:(DTConfiguration *)config planName:(NSString *)planName;

+ (NSArray *)plansInContext:(NSManagedObjectContext *)context;

@property (nonatomic) NSSet *editableFieldNames;
@property (nonatomic) NSSet *optionRules;


@property (nonatomic, readonly) NSArray *sortedSteps;
- (DTPlanStep *)stepWithValue:(NSString *)value;

@end

@interface DTPlan (CoreDataGeneratedAccessors)

- (void)addEditableFieldsObject:(DTPlanField *)value;
- (void)removeEditableFieldsObject:(DTPlanField *)value;
- (void)addEditableFields:(NSSet *)values;
- (void)removeEditableFields:(NSSet *)values;

- (void)addStepsObject:(DTPlanStep *)step;
- (void)removeStepsObject:(DTPlanStep *)step;
- (void)addSteps:(NSSet *)steps;
- (void)removeSteps:(NSSet *)steps;

@end
