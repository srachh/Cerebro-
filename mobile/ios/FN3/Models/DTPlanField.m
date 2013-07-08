//
//  DTPlanField.m
//  FN3
//
//  Created by David Jablonski on 5/1/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPlanField.h"

@implementation DTPlanField

@dynamic name;

+ (DTPlanField *)createFieldInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

@end
