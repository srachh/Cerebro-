//
//  DTEquipmentAnnotation.m
//  FN3
//
//  Created by David Jablonski on 5/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentAnnotation.h"
#import "DTEquipment.h"

@implementation DTEquipmentAnnotation

@synthesize identifier, type, icon, coordinate;

- (id)initWithEquipment:(DTEquipment *)equipment
{
    if (self = [super init]) {
        coordinate = CLLocationCoordinate2DMake(equipment.latitude.floatValue, 
                                                equipment.longitude.floatValue);
        [self updateFromEquipment:equipment];
    }
    return self;
}

- (NSString *)title
{
    return title;
}

- (NSString *)subtitle
{
    return subtitle;
}

- (void)updateFromEquipment:(DTEquipment *)equipment
{
    identifier = equipment.identifier;
    title = equipment.title;
    subtitle = equipment.subtitle;
    size = equipment.size;
    type = equipment.entity.name;
    
    // this will re-draw on the map
    if (equipment.latitude.doubleValue != self.coordinate.latitude || equipment.longitude.doubleValue != self.coordinate.longitude) {
        self.coordinate = CLLocationCoordinate2DMake(equipment.latitude.floatValue, 
                                                     equipment.longitude.floatValue);
    }
}

-(MKMapRect)boundingMapRect
{
    CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude);
    CGSize sizeInMeters = size;
    
    // size in meters 100 meters
    MKMapSize mapSize = MKMapSizeMake(sizeInMeters.width * mapPointsPerMeter, sizeInMeters.height * mapPointsPerMeter);
    
    CLLocationCoordinate2D point = coordinate;
    
    if ( !CLLocationCoordinate2DIsValid(point) )
    {
        NSLog(@"Coordinate is not valid.");
    }
    
    // grab the current mappoint
    MKMapPoint coordinateMapPoint = MKMapPointForCoordinate(point);
    
    
    // the number of map points positive or negative to the edge
    double x =  ( coordinateMapPoint.x - ( mapSize.width / 2 ) );
    double y = ( coordinateMapPoint.y - ( mapSize.height / 2 ) );
    
    MKMapRect mapRect = MKMapRectMake(x, y, mapSize.width, mapSize.height);
    
    if ( MKMapRectIsNull(mapRect) )
    {
        NSLog(@"MapRect is invalid!!");
    }
    
    return mapRect;
}

@end
