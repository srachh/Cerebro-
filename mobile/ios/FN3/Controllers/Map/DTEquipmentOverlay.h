//
//  CriOverlayView.h
//  FN3
//
//  Created by David Jablonski on 5/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol DTMapOverlay <NSObject>
@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) UIView *view;
@property (nonatomic) MKMapRect rect;
@end


@interface DTEquipmentOverlay : NSObject <MKOverlay> {
    NSMutableDictionary *overlays;
    MKOverlayView *overlayView;
}

@property (nonatomic, readonly) MKOverlayView *overlayView;
@property (nonatomic, readonly) NSArray *overlays;

- (void)addOverlayView:(UIView *)view at:(MKMapRect)rect identifier:(NSNumber *)identifier;

- (id<DTMapOverlay>)overlayForId:(NSNumber *)identifier;

- (void)removeOverlay:(id<DTMapOverlay>)overlay;

@end
