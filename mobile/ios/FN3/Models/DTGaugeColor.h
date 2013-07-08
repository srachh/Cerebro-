//
//  DTGaugeColor.h
//  FN3
//
//  Created by David Jablonski on 5/9/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTGauge;

@interface DTGaugeColor : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) DTGauge *gauge;

@end
