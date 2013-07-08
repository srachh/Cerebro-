//
//  DTPlanField.h
//  FN3
//
//  Created by David Jablonski on 5/1/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DTPlanField : NSManagedObject

@property (nonatomic, retain) NSString * name;

+ (DTPlanField *)createFieldInContext:(NSManagedObjectContext *)context;

@end
