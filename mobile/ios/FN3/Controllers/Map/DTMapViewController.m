//
//  DTMapViewController.m
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTMapViewController.h"
#import "DTEquipmentGroup.h"
#import "DTEquipment.h"
#import "DTPersistentStore.h"
#import "MKMapView+MapViewUtilities.h"
#import "NSArray+DTArray.h"
#import "UIColor+DTColor.h"

#import "DTPivot.h"
#import "DTPumpStation.h"
#import "DTGeneralIO.h"
#import "DTLateral.h"

#import "DTDashboardViewController.h"
#import "DTPumpView.h"
#import "DTPivotView.h"
#import "DTLateralView.h"

#import "DTButton.h"
#import "DTLinearGradientShader.h"
#import "DTSolidShader.h"
#import "UIView+DTCustomViews.h"
#import "DTView.h"

#import "DTEquipmentOverlay.h"
#import "DTEquipmentOverlayView.h"
#import "DTEquipmentAnnotation.h"

#import "DTConnection.h"
#import "DTResponse.h"
#import "NSOperationQueue+DTOperationQueue.h"
#import "DTEquipmentParser.h"
#import "DTAppDelegate.h"

#import "DTMapOptionsViewController.h"

#import "DTAnalytics.h"

@implementation DTMapViewController

@synthesize group;
@synthesize locationButton;
@synthesize layersButton;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    store = [[DTPersistentStore alloc] init];
    
    annotationsById = [[NSMutableDictionary alloc] init];
    [self loadAnnotations];
    // set up the initial view port
    if ([(MKMapView *)self.view annotations].count > 0) {
        DTEquipmentAnnotation *first = [[(MKMapView *)self.view annotations] objectAtIndex:0];
        MKMapRect rect = [first boundingMapRect];
        for (DTEquipmentAnnotation *annotation in [(MKMapView *)self.view annotations]) {
            rect = MKMapRectUnion(rect, [annotation boundingMapRect]);
        }
        [(MKMapView *)self.view setRegion:MKCoordinateRegionForMapRect(rect)];
    }
    
    UIBarButtonItem *layersItem = [[UIBarButtonItem alloc] initWithCustomView:layersButton];
    UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithCustomView:locationButton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:layersItem, userItem, nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onEquipmentListUpdate) 
                                                 name:DTEquipmentUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onEquipmentDetailUpdate:) 
                                                 name:DTEquipmentDetailUpdate 
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    UIBarButtonItem *item = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
//    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
//        item.enabled = NO;
//    } else {
//        item.enabled = YES;
//    }
    
    [refreshTimer invalidate];
    if (self.navigationController) {
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:15 
                                                        target:self 
                                                      selector:@selector(refreshData) 
                                                      userInfo:nil 
                                                       repeats:YES];
        isRunningRefresh = NO;
        [refreshTimer fire];
    }
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    store = nil;
    annotationsById = nil;
    
    [(MKMapView *)self.view removeOverlay:overlays];
    overlays = nil;
    
    [self setLocationButton:nil];
    [self setLayersButton:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)refreshData
{
    if (!isRunningRefresh) {
        [[NSOperationQueue networkQueue] addNetworkOperationWithBlock:^(void){
            isRunningRefresh = YES;
            
            DTResponse *groupsResponse = [DTConnection getTo:FN3APIGroupList parameters:nil];
            if (groupsResponse.isSuccess) {
                DTResponse *listResponse = [DTConnection getTo:FN3APIEquipmentList parameters:nil];
                if (listResponse.isSuccess) {
                    NSOperation *op = [[DTEquipmentParser alloc] initWithGroupsResponse:groupsResponse.data
                                                                           listResponse:listResponse.data];
                    op.completionBlock = ^(void){
                        isRunningRefresh = NO;
                    };
                    [[NSOperationQueue parserQueue] addOperation:op];
                } else {
                    if (listResponse.isAuthenticationError) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                            [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                        }];
                    }
                    
                    isRunningRefresh = NO;
                }
            } else {
                if (groupsResponse.isAuthenticationError) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                    }];
                }
                
                isRunningRefresh = NO;
            }
        }];
    }
}

- (NSFetchRequest *)newFetchRequest
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[[DTEquipment class] description]];
    
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
    if (self.searchDisplayController.searchBar.text.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"title BEGINSWITH[c] %@", self.searchDisplayController.searchBar.text]];
    }
    if (self.group) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"groups CONTAINS %@", self.group]];
    }
    if (predicates.count >  0) {
        request.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType 
                                                        subpredicates:predicates];
    }
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    return request;
}

- (void)addEquipment:(DTEquipment *)equipment
{
    if (!equipment.latitude || !equipment.longitude) {
        return;
    }
    
    DTEquipmentAnnotation *annotation = [[DTEquipmentAnnotation alloc] initWithEquipment:equipment];
    
    if ([equipment isKindOfClass:[DTPivot class]]) {
        CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(equipment.latitude.floatValue);
        
        DTPivotView *view = [[DTPivotView alloc] init];
        [view configureFromEquipment:equipment];
        view.borderWidth = 35 * mapPointsPerMeter;
        view.detailLevel = DTEquipmentDetailLevelMap;
        
        [overlays addOverlayView:view 
                              at:[annotation boundingMapRect] 
                      identifier:equipment.identifier];
    } else if ([equipment isKindOfClass:[DTPumpStation class]]) {
        DTPumpView *view = [[DTPumpView alloc] init];
        [view configureFromEquipment:equipment];
        view.frame = CGRectMake(0, 0, 32, 32);

        UIGraphicsBeginImageContext(view.frame.size);
        [view drawRect:view.frame];
        annotation.icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else if ([equipment isKindOfClass:[DTLateral class]]) {
        CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(equipment.latitude.floatValue);
        
        DTLateralView *view = [[DTLateralView alloc] init];
        [view configureFromEquipment:equipment];
        view.borderWidth = 35 * mapPointsPerMeter;
        view.detailLevel = DTEquipmentDetailLevelMap;
        
        [overlays addOverlayView:view
                              at:[annotation boundingMapRect]
                      identifier:equipment.identifier];
        
    } else if ([equipment isKindOfClass:[DTGeneralIO class]]) {
        annotation.icon = [(DTGeneralIO *)equipment icon];
    }
    
    [(MKMapView *)self.view addAnnotation:annotation];
    [annotationsById setObject:annotation forKey:equipment.identifier];
}

-(void)loadAnnotations
{
    DTPersistentStore *ps = [[DTPersistentStore alloc] init];
    NSFetchedResultsController *results = [[NSFetchedResultsController alloc] initWithFetchRequest:[self newFetchRequest]
                                                                              managedObjectContext:ps.managedObjectContext 
                                                                                sectionNameKeyPath:nil 
                                                                                         cacheName:nil];
    
    NSError *error;
    [results performFetch:&error];
    
    overlays = [[DTEquipmentOverlay alloc] init];
    [(MKMapView *)self.view addOverlay:overlays];
    for (DTEquipment *equipment in [[results.sections objectAtIndex:0] objects]) {
        [self addEquipment:equipment];
    }
}

- (void)onEquipmentDetailUpdate:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        DTPersistentStore *ps = [[DTPersistentStore alloc] init];
        for (NSNumber *identifier in notification.object) {
            DTEquipment *equipment = [DTEquipment equipmentWithId:identifier 
                                                        inContext:ps.managedObjectContext];
            
            DTEquipmentAnnotation *annotation = [annotationsById objectForKey:identifier];
            if (annotation) {
                [annotation updateFromEquipment:equipment];
                
                id<DTMapOverlay> o = [overlays overlayForId:equipment.identifier];
                if (o) {
                    if ([o.view conformsToProtocol:@protocol(DTEquipmentView)]) {
                        [(id<DTEquipmentView>)o.view configureFromEquipment:equipment];
                    }
                    o.rect = [annotation boundingMapRect];
                }
            }
        }
    }];
}

- (void)onEquipmentListUpdate
{
    if ([(MKMapView *)self.view overlays].count > 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
            DTPersistentStore *ps = [[DTPersistentStore alloc] init];
            NSFetchedResultsController *results = [[NSFetchedResultsController alloc] initWithFetchRequest:[self newFetchRequest]
                                                                                      managedObjectContext:ps.managedObjectContext 
                                                                                        sectionNameKeyPath:nil 
                                                                                                 cacheName:nil];
            
            NSError *error;
            [results performFetch:&error];
            
            NSMutableSet *foundIdentifiers = [[NSMutableSet alloc] initWithCapacity:annotationsById.count];
            for (DTEquipment *equipment in [[results.sections objectAtIndex:0] objects]) {
                DTEquipmentAnnotation *a = [annotationsById objectForKey:equipment.identifier];
                if (a) {
                    [a updateFromEquipment:equipment];
                    
                    id<DTMapOverlay> o = [overlays overlayForId:equipment.identifier];
                    if (o) {
                        if ([o.view conformsToProtocol:@protocol(DTEquipmentView)]) {
                            [(id<DTEquipmentView>)o.view configureFromEquipment:equipment];
                        }
                        o.rect = [a boundingMapRect];
                    }
                } else {
                    // new piece of equipment, add it
                    [self addEquipment:equipment];
                }
                
                [foundIdentifiers addObject:equipment.identifier];
            }
            
            // remove anything that was not found
            for (DTEquipmentAnnotation *a in annotationsById.allValues) {
                if (![foundIdentifiers containsObject:a.identifier]) {
                    [(MKMapView *)self.view removeAnnotation:a];
                    
                    id<DTMapOverlay> o = [overlays overlayForId:a.identifier];
                    if (o) {
                        [overlays removeOverlay:o];
                    }
                    
                    [annotationsById removeObjectForKey:a.identifier];
                }
            }
        }];
        
        [overlays.overlayView setNeedsDisplay];
    }
}

- (IBAction)showUserLocation:(id)sender
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if ([(MKMapView *)self.view showsUserLocation]) {
            [(MKMapView *)self.view setShowsUserLocation:YES];
            MKUserLocation *location = [(MKMapView *)self.view userLocation];
            [(MKMapView *)self.view setRegion:MKCoordinateRegionMake([location coordinate], 
                                                                     MKCoordinateSpanMake(.005, .005)) 
                                     animated:YES];
        } else {
            zoomToUserOnLocationChange = YES;
            [(MKMapView *)self.view setShowsUserLocation:YES];
        }
    }
    else {
        // pop up to say they need to enable location services
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services", nil) message:NSLocalizedString(@"Please turn on Location Services to use this feature.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"SegueToMapOptionsScene" isEqualToString:segue.identifier]) {
        DTMapOptionsViewController *c = segue.destinationViewController;
        c.mapView = (MKMapView *)self.view;
    }
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if (zoomToUserOnLocationChange) {
            zoomToUserOnLocationChange = NO;
            
            [(MKMapView *)self.view setRegion:MKCoordinateRegionMake([userLocation coordinate], 
                                                                     MKCoordinateSpanMake(.005, .005)) 
                                     animated:YES];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[DTEquipmentAnnotation class]]) {
        MKPinAnnotationView *view = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:@"MapPin"];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapPin"];
            view.animatesDrop = YES;
            view.canShowCallout = YES;
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        DTEquipmentAnnotation *ea = annotation;
        if ([[[DTPivot class] description] isEqualToString:ea.type] || [[[DTLateral class] description] isEqualToString:ea.type]) {
            view.pinColor = MKPinAnnotationColorRed;
        } else if ([[[DTPumpStation class] description] isEqualToString:ea.type]) {
            view.pinColor = MKPinAnnotationColorGreen;
        } else {
            view.pinColor = MKPinAnnotationColorPurple;
        }
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:ea.icon];
        
        return view;
    } else {
        return nil;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return overlays.overlayView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    DTEquipmentAnnotation *annotation = view.annotation;
    id<DTDashboardViewController> dashboardController = nil;
    
    UIStoryboard *storyBoard = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil ];
    
    if ([[[DTPivot class] description] isEqualToString:annotation.type]) {
        dashboardController = [storyBoard instantiateViewControllerWithIdentifier:@"pivotDashboard"];
    } else if ([[[DTLateral class] description] isEqualToString:annotation.type]) {
        dashboardController = [storyBoard instantiateViewControllerWithIdentifier:@"lateralDashboard"];
    } else if ([[[DTPumpStation class] description] isEqualToString:annotation.type]) {
        dashboardController = [storyBoard instantiateViewControllerWithIdentifier:@"pumpDashboard"];
    } else if ([[[DTGeneralIO class] description] isEqualToString:annotation.type]) {
        dashboardController = [storyBoard instantiateViewControllerWithIdentifier:@"generalIODashboard"];
    }
    
    if (dashboardController) {
        dashboardController.equipmentId = annotation.identifier;
        
        [self.navigationController pushViewController:(UIViewController *)dashboardController 
                                             animated:YES ];
    }
}

@end
