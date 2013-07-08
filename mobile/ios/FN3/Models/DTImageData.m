//
//  DTImage.m
//  FN3
//
//  Created by David Jablonski on 5/1/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTImageData.h"


@implementation DTImageData

@dynamic path;
@dynamic data;

+ (DTImageData *)imageDataForPath:(NSString *)path 
                        inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"path = %@", path];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)imageDataInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

@end
