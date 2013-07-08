//
//  DTMapViewController.h
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DTPersistentStore, DTEquipmentGroup, DTButton, DTView;
@class DTEquipmentOverlay;

@interface DTMapViewController : UIViewController <MKMapViewDelegate> {
    DTEquipmentGroup *group;
    
    NSMutableDictionary *annotationsById;
    DTEquipmentOverlay *overlays;
    
    DTPersistentStore *store;
    NSFetchedResultsController *resultsController;
    
    BOOL zoomToUserOnLocationChange;
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
}

@property (nonatomic, retain) DTEquipmentGroup *group;

@property (strong, nonatomic) IBOutlet DTButton *locationButton;
@property (strong, nonatomic) IBOutlet DTButton *layersButton;

- (IBAction)showUserLocation:(id)sender;

@end
