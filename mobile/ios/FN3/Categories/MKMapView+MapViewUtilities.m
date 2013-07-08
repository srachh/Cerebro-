//
//  MKMapView+MapViewUtilities.m
//  FN3
//
//  Created by Hasani Hunter on 4/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "MKMapView+MapViewUtilities.h"
#import <math.h>

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (MapViewUtilities)

// inspiration from http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/
-(NSInteger)zoomLevel
{
    NSInteger maxZoomLevel = 21;
    NSInteger roundedZoom = round(log2(self.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.bounds.size.width))); 
    return maxZoomLevel - roundedZoom;
}

@end
