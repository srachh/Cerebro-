//
//  DTMapOptionsViewController.h
//  FN3
//
//  Created by David Jablonski on 5/4/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKMapView;

@interface DTMapOptionsViewController : UIViewController {
    MKMapView *mapView;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

- (IBAction)mapViewSelected:(id)sender;

@end
