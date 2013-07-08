//
//  DTGaugeMarker.h
//  FN3
//
//  Created by David Jablonski on 5/9/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTGauge;

@interface DTGaugeMarker : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * fillColor;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) DTGauge *gauge;

@end
