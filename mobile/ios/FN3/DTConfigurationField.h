//
//  Models.h
//  FN3
//
//  Created by David Jablonski on 4/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DTConfigurationField : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * requiresWater;

+ (DTConfigurationField *)createFieldInContext:(NSManagedObjectContext *)context;

@end
