//
//  DTGauge.h
//  FN3
//
//  Created by David Jablonski on 5/9/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTPumpStation;

@interface DTGauge : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) DTPumpStation *pumpStation;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) NSSet *markers;
@end

@interface DTGauge (CoreDataGeneratedAccessors)

- (void)addColorsObject:(NSManagedObject *)value;
- (void)removeColorsObject:(NSManagedObject *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

- (void)addMarkersObject:(NSManagedObject *)value;
- (void)removeMarkersObject:(NSManagedObject *)value;
- (void)addMarkers:(NSSet *)values;
- (void)removeMarkers:(NSSet *)values;

@end
