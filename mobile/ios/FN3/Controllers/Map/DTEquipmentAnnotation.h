//
//  DTEquipmentAnnotation.h
//  FN3
//
//  Created by David Jablonski on 5/8/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class DTEquipment;

@interface DTEquipmentAnnotation : NSObject <MKAnnotation> {
    NSNumber *identifier;
    NSString *title, *subtitle, *type;
    CLLocationCoordinate2D coordinate;
    CGSize size;
    UIImage *icon;
}

@property (nonatomic, readonly) NSNumber *identifier;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithEquipment:(DTEquipment *)equipment;

- (void)updateFromEquipment:(DTEquipment *)equipment;

-(MKMapRect)boundingMapRect;

@end
