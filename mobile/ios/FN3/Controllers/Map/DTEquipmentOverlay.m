//
//  CriOverlayView.m
//  FN3
//
//  Created by David Jablonski on 5/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentOverlay.h"
#import "DTEquipmentOverlayView.h"


@interface DTMapOverlayImpl : NSObject <DTMapOverlay>
@end

@implementation DTMapOverlayImpl
@synthesize view, rect, identifier;
@end


@implementation DTEquipmentOverlay

@synthesize overlayView;

- (id)init
{
    if (self = [super init]) {
        overlays = [[NSMutableDictionary alloc] init];
        overlayView = [[DTEquipmentOverlayView alloc] initWithOverlay:self];
    }
    return self;
}

- (void)addOverlayView:(UIView *)view at:(MKMapRect)rect identifier:(NSNumber *)identifier
{
    id<DTMapOverlay> d = [[DTMapOverlayImpl alloc] init];
    d.view = view;
    d.rect = rect;
    d.identifier = identifier;
    [overlays setObject:d forKey:identifier];
}

- (NSArray *)overlays
{
    return overlays.allValues;
}

- (id<DTMapOverlay>)overlayForId:(NSNumber *)identifier
{
    return [overlays objectForKey:identifier];
}

- (void)removeOverlay:(id<DTMapOverlay>)overlay
{
    [overlays removeObjectForKey:overlay.identifier];
}

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(0, 0);
}

-(MKMapRect)boundingMapRect
{
    return MKMapRectWorld;
}

@end
