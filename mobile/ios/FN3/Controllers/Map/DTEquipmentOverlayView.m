//
//  CriMapOverlayView.m
//  FN3
//
//  Created by David Jablonski on 5/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentOverlayView.h"
#import "DTEquipmentOverlay.h"

@implementation DTEquipmentOverlayView

- (void)drawMapRect:(MKMapRect)mapRect 
          zoomScale:(MKZoomScale)zoomScale 
          inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    DTEquipmentOverlay *mapOverlay = (DTEquipmentOverlay *)self.overlay;
    for (id<DTMapOverlay> overlay in mapOverlay.overlays) {
        if (MKMapRectIntersectsRect(mapRect, overlay.rect)) {
            CGRect rect = [self rectForMapRect:overlay.rect];

            CGContextSaveGState(context);
            CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
            
            overlay.view.frame = rect;
            [overlay.view drawRect:rect];
            
            CGContextRestoreGState(context);
        }
    }
    
    UIGraphicsPopContext();
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    return YES;
}


@end
