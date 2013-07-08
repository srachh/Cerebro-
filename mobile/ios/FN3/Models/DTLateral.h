//
//  DTLateral.h
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTEquipment.h"
#import <CoreData/CoreData.h>


@interface DTLateral : DTEquipment

@property (nonatomic, retain) NSNumber * planId;
@property (nonatomic, retain) NSString * planStepValue;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, readonly) NSNumber * depth;
@property (nonatomic, retain) NSString * depthUom;
@property (nonatomic, retain) NSNumber * depthConversionFactor;
@property (nonatomic, retain) NSNumber * water;
@property (nonatomic, retain) NSNumber * repeatServiceStop;

@property (nonatomic, readonly) DTEquipmentDataField *pressure;
@property (nonatomic, readonly) DTEquipmentDataField *flow;
@property (nonatomic, readonly) DTEquipmentDataField *voltage;
@property (nonatomic, readonly) DTEquipmentDataField *temperature;
@property (nonatomic, readonly) DTEquipmentAccessoryField *chemigation;
@property (nonatomic, readonly) DTEquipmentAccessoryField *accessoryOne;
@property (nonatomic, readonly) DTEquipmentAccessoryField *accessoryTwo;

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * directionOption;
@property (nonatomic, retain) NSString * directionDescription;
@property (nonatomic, readonly) DTEquipmentDirection direction;

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * positionUom;
@property (nonatomic, retain) NSNumber * servicePosition;
@property (nonatomic, retain) NSString * servicePositionUom;

@property (nonatomic, retain) NSNumber * trailStart;
@property (nonatomic, retain) NSNumber * trailStop;

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, readonly) NSString * durationDescription;

@property (nonatomic, retain) NSNumber * heightMeters;
@property (nonatomic, retain) NSNumber * widthMeters;
@property (nonatomic, retain) NSNumber * mapHeightMeters;
@property (nonatomic, retain) NSNumber * mapWidthMeters;
@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSNumber * pumpType;
@property (nonatomic, retain) NSString * hoseStopPositions;

- (NSNumber *)depthForRate:(NSNumber *)rate;
- (NSNumber *)rateForDepth:(NSNumber *)depth;
- (NSArray *)hoseStopPositionsArray;
- (Boolean)isPumpTypeEngine;

@end
