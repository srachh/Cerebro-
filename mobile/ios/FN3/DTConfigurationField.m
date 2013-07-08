//
//  Models.m
//  FN3
//
//  Created by David Jablonski on 4/27/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTConfigurationField.h"


@implementation DTConfigurationField

@dynamic name;

+ (DTConfigurationField *)createFieldInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

@end
