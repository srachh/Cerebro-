//
//  DTImage.h
//  FN3
//
//  Created by David Jablonski on 5/1/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DTImageData : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSData * data;

+ (DTImageData *)imageDataForPath:(NSString *)path 
                        inContext:(NSManagedObjectContext *)context;

+ (NSArray *)imageDataInContext:(NSManagedObjectContext *)context;

@end
