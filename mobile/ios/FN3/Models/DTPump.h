//
//  DTPump.h
//  FN3
//
//  Created by David Jablonski on 4/26/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    DTPumpStateNormal        = 0,
    DTPumpStateLocked        = 1,
    DTPumpStatePressurizing  = 2,
    DTPumpStateRegulating    = 3
};
typedef NSUInteger DTPumpState;


@class DTPumpStation;

@interface DTPump : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * hoa;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * statusDescription;

@property (nonatomic, retain) DTPumpStation *station;

@property (nonatomic, readonly) DTPumpState state;

+ (DTPump *)createPumpInContext:(NSManagedObjectContext *)context;

@end
