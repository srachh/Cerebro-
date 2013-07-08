//
//  DTPlanStep.h
//  FieldNET
//
//  Created by David Jablonski on 9/4/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTPlan;

@interface DTPlanStep : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) DTPlan *plan;

@end
