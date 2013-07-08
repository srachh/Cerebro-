//
//  DTMapOptionsViewController.m
//  FN3
//
//  Created by David Jablonski on 5/4/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTMapOptionsViewController.h"
#import <MapKit/MapKit.h>

#import "DTAnalytics.h"


@implementation DTMapOptionsViewController

@synthesize mapView;
@synthesize mapTypeControl;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.mapView.mapType == MKMapTypeStandard) {
        self.mapTypeControl.selectedSegmentIndex = 0;
    } else if (self.mapView.mapType == MKMapTypeSatellite) {
        self.mapTypeControl.selectedSegmentIndex = 1;
    } else {
        self.mapTypeControl.selectedSegmentIndex = 2;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mapViewSelected:(id)sender
{
    UISegmentedControl *control = sender;
    if (control.selectedSegmentIndex == 0) {
        self.mapView.mapType = MKMapTypeStandard;
    } else if (control.selectedSegmentIndex == 1) {
        self.mapView.mapType = MKMapTypeSatellite;
    } else {
        self.mapView.mapType = MKMapTypeHybrid;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setMapTypeControl:nil];
    [super viewDidUnload];
}
@end
