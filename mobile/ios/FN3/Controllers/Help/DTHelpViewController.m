//
//  HelpViewController.m
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTHelpViewController.h"
#import "DTHelpText.h"
#import "DTTranslation.h"
#import "DTSearchTableDisplayController.h"
#import "UIView+DTCustomViews.h"
#import "DTConnectionView.h"
#import "DTHelpSearchDataSource.h"
#import "DTPivotView.h"
#import "DTLateralView.h"
#import "DTPumpView.h"
#import "DTPumpStationView.h"
#import "DTConfiguration.h"
#import "DTGPIOType.h"

#import "DTFunctions.h"
#import "UIColor+DTColor.h"
#import "DTPersistentStore.h"

#import "DTAnalytics.h"

#import "DTConnection.h"


@implementation DTHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(UITableView *)self.view setBackgroundView:nil];
    
    store = [[DTPersistentStore alloc] init];
    
    searchDataSource = [[DTHelpSearchDataSource alloc] initWithTableView:(UITableView *)self.view];
    searchDataSource.searchDisplayController = searchBarDisplayController;
    searchBarDisplayController.tableViewDelegate = searchDataSource;
    searchBarDisplayController.tableViewDataSource = searchDataSource;
    
    sizedIndexPaths = [[NSMutableArray alloc] init];
    
    [self reloadTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configurationUpdate:)
                                                 name:DTConfigurationUpdate
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
}

- (void)viewDidUnload
{
    sizedIndexPaths = nil;
    searchDataSource = nil;
    iconController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

- (IBAction)viewFullSite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[DTConnection getHost]]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // Menu section
        return 12;
    } else if (section == 1) {
        // Map View section
        return 5;
    } else if (section == 2) {
        // Equipment section
        id<NSFetchedResultsSectionInfo> section = iconController.sections.lastObject;
        NSInteger count = [section numberOfObjects];
        return 4 + count;
    } else if (section == 3) {
        // Pivot section
        return 14;
    } else if (section == 4) {
        // Lateral section
        return 14;
    } else {
        // Pump Station section
        //return 10;
        return 9;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Menu", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Map View", nil);;
    } else if (section == 2) {
        return NSLocalizedString(@"Equipment", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"Irrigation System - Pivot", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"Irrigation System - Lateral", nil);
    } else {
        return NSLocalizedString(@"Pump Station", nil);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView tableHeaderViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        // Menu section
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"help_tab.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Displays this Help screen", nil);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"full_site.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"View full website", nil);
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"list_tab.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Shows a List of Equipment", nil);
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"map_tab.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Shows Map View of Equipment", nil);
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"alert_tab.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Shows a List of Alerts", nil);
        } else if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"settings_tab.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Shows Profile for updating application settings and configuration", nil);
        } else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"logout_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Log out of FieldNET Application", nil);
        } else if (indexPath.row == 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommHelpCell"];
            DTConnectionView *img = (DTConnectionView *)[cell viewWithTag:1];
            img.commStatus = DTCommStatusGreen;
            img.accessoryColor = [UIColor blackColor];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Communication Status - Online without any issues in the last 24 hours", nil);
        } else if (indexPath.row == 8) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommHelpCell"];
            DTConnectionView *img = (DTConnectionView *)[cell viewWithTag:1];
            img.commStatus = DTCommStatusYellow;
            img.accessoryColor = [UIColor blackColor];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Communication Status - Online with issues in the last 24 hours", nil);
        } else if (indexPath.row == 9) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommHelpCell"];
            DTConnectionView *img = (DTConnectionView *)[cell viewWithTag:1];
            img.commStatus = DTCommStatusRed;
            img.accessoryColor = [UIColor blackColor];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Communication Status - Unexpectedly offline", nil);
        } else if (indexPath.row == 10) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommHelpCell"];
            DTConnectionView *img = (DTConnectionView *)[cell viewWithTag:1];
            img.commStatus = DTCommStatusGray;
            img.accessoryColor = [UIColor blackColor];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Communication Status - Offline", nil);
        } else if (indexPath.row == 11) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"poll_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Poll the Equipment and update screen with changes", nil);
        }
    } else if (indexPath.section == 1) {
        // Map View section
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
        if (indexPath.row == 0) {
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"layers_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Change Map layer type", nil);
        } else if (indexPath.row == 1) {
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"pointer_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Shows your location on the Map View (requires enabling mobile device location services)", nil);
        } else if (indexPath.row == 2) {
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"Pin.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Irrigation System - Pivots and Laterals", nil);
        } else if (indexPath.row == 3) {
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"PinGreen.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station", nil);
        } else if (indexPath.row == 4) {
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"PinPurple.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Sensors and Relays", nil);
        }
    } else if (indexPath.section == 2) {
        // Equipment section
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor lightGrayColor];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = -1;
            img.currentAngle = DTRadiansFromDegrees(135);
            img.trailStartAngle = img.currentAngle;
            img.trailStopAngle = DTRadiansFromDegrees(361);
            img.borderColor = [UIColor blackColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Irrigation System - Pivot", nil);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor lightGrayColor];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = 787;
            img.height = 386;
            img.positionPercent = 0.8;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = -1;
            img.trailStartPercent = -1;
            img.trailStopPercent = -1;
            img.borderColor = [UIColor blackColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Irrigation System - Lateral", nil);
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpStationHelpCell"];
            DTPumpStationView *img = (DTPumpStationView*)[cell viewWithTag:1];
            img.color = [UIColor blackColor];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station", nil);
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"io_help.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Sensors and Relays", nil);
        } else {
            // GPIO icons from datase
            DTGPIOType *gpioType = [iconController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 4 inSection:0]];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = gpioType.icon;
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = gpioType.typeDescription;
        }
    } else if (indexPath.section == 3) {
        // Pivot section
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"angle.png"];
            [img setContentMode:UIViewContentModeLeft];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Current Position", nil);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"duration.png"];
            [img setContentMode:UIViewContentModeLeft];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Circle Time", nil);
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"forward_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Forward direction Status or Control", nil);
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"reverse_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Reverse direction Status or Control", nil);
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"started_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Started Status or Control", nil);
        } else if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"stop_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Stop Status or Control", nil);
        } else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"flow_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Wet or Dry Status or Control", nil);
        } else if (indexPath.row == 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"direction_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Service Stop based on position", nil);
        } else if (indexPath.row == 8) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"auto_repeat_stop_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Repeat Service Stop", nil);
        } else if (indexPath.row == 9) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.54 green:.77 blue:.24 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = -1;
            img.currentAngle = DTRadiansFromDegrees(45);
            img.trailStartAngle = DTRadiansFromDegrees(45);
            img.trailStopAngle = DTRadiansFromDegrees(135);
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running Dry", nil);
        } else if (indexPath.row == 10) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.14 green:.6 blue:.96 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = DTRadiansFromDegrees(270);
            img.currentAngle = DTRadiansFromDegrees(225);
            img.trailStartAngle = DTRadiansFromDegrees(90);
            img.trailStopAngle = DTRadiansFromDegrees(135);
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running Wet", nil);
        } else if (indexPath.row == 11) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:1 green:.4 blue:0 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = -1;
            img.currentAngle = DTRadiansFromDegrees(315);
            img.trailStartAngle = DTRadiansFromDegrees(90);
            img.trailStopAngle = DTRadiansFromDegrees(-135);
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running with Accessory or Chemical", nil);
        } else if (indexPath.row == 12) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.75 green:.15 blue:.17 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = -1;
            img.currentAngle = DTRadiansFromDegrees(135);
            img.trailStartAngle = DTRadiansFromDegrees(225);
            img.trailStopAngle = DTRadiansFromDegrees(270);
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Has Alert", nil);
        } else if (indexPath.row == 13) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PivotHelpCell"];
            DTPivotView *img = (DTPivotView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.serviceAngle = -1;
            img.currentAngle = 0;
            img.trailStartAngle = img.currentAngle;
            img.trailStopAngle = DTRadiansFromDegrees(361);
            img.borderColor = [UIColor darkGrayColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Stopped", nil);
        }
    } else if (indexPath.section == 4) {
        // Lateral section
        CGFloat lateralWidth = 787;
        CGFloat lateralHeight = 386;
        CGFloat lateralPositionPercent = 0.5;
        CGFloat lateralServiceStopPercent = 0.95;
        CGFloat lateralTrailStartPercent = 0;
        CGFloat lateralTrailStopPercent = 0.5;
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_position.png"];
            img.contentMode = UIViewContentModeScaleAspectFit;
            [img setContentMode:UIViewContentModeLeft];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Current Position", nil);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_duration.png"];
            [img setContentMode:UIViewContentModeLeft];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Full Run Time", nil);
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_forward_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Forward direction Status or Control", nil);
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_reverse_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Reverse direction Status or Control", nil);
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"stop_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Stop Status or Control", nil);
        } else if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"flow_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Wet or Dry Status or Control", nil);
        } else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_pump_black.png"];
            [img setContentMode:UIViewContentModeScaleAspectFit];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Engine Status", nil);
        } else if (indexPath.row == 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"lateral_service_stop_black.png"];
            [img setContentMode:UIViewContentModeScaleAspectFit];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Service Stop based on position", nil);
        } else if (indexPath.row == 8) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageHelpCell"];
            UIImageView *img = (UIImageView *)[cell viewWithTag:1];
            img.image = [UIImage imageNamed:@"auto_repeat_stop_black.png"];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Repeat Service Stop", nil);
        } else if (indexPath.row == 9) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.54 green:.77 blue:.24 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = lateralWidth;
            img.height = lateralHeight;
            img.positionPercent = lateralPositionPercent;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = lateralServiceStopPercent;
            img.trailStartPercent = lateralTrailStartPercent;
            img.trailStopPercent = lateralTrailStopPercent;
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionForward;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running Dry", nil);
        } else if (indexPath.row == 10) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.14 green:.6 blue:.96 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = lateralWidth;
            img.height = lateralHeight;
            img.positionPercent = lateralPositionPercent;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = lateralServiceStopPercent;
            img.trailStartPercent = lateralTrailStartPercent;
            img.trailStopPercent = lateralTrailStopPercent;
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionForward;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running Wet", nil);
        } else if (indexPath.row == 11) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:1 green:.4 blue:0 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = lateralWidth;
            img.height = lateralHeight;
            img.positionPercent = lateralPositionPercent;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = lateralServiceStopPercent;
            img.trailStartPercent = lateralTrailStartPercent;
            img.trailStopPercent = lateralTrailStopPercent;
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionForward;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Running with Accessory or Chemical", nil);
        } else if (indexPath.row == 12) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.75 green:.15 blue:.17 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = lateralWidth;
            img.height = lateralHeight;
            img.positionPercent = lateralPositionPercent;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = lateralServiceStopPercent;
            img.trailStartPercent = lateralTrailStartPercent;
            img.trailStopPercent = lateralTrailStopPercent;
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionForward;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Has Alert", nil);
        } else if (indexPath.row == 13) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LateralHelpCell"];
            DTLateralView *img = (DTLateralView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
            img.detailLevel = DTEquipmentDetailLevelList;
            img.width = lateralWidth;
            img.height = lateralHeight;
            img.positionPercent = lateralPositionPercent;
            img.positionColor = [UIColor blackColor];
            img.serviceStopPercent = lateralServiceStopPercent;
            img.trailStartPercent = lateralTrailStartPercent;
            img.trailStopPercent = lateralTrailStopPercent;
            img.borderColor = [img.color darkerColor];
            img.direction = DTEquipmentDirectionStopped;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Stopped", nil);
        }
    } else if (indexPath.section == 5) {
        // Pump Station section
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpStationHelpCell"];
            DTPumpStationView *img = (DTPumpStationView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed: 0.08 green: 0.49 blue: 0.97 alpha: 1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station - Running", nil);
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpStationHelpCell"];
            DTPumpStationView *img = (DTPumpStationView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.75 green:.15 blue:.17 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station - Alert", nil);
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpStationHelpCell"];
            DTPumpStationView *img = (DTPumpStationView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:1 green:.4 blue:0 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station - Running with Chemical", nil);
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpStationHelpCell"];
            DTPumpStationView *img = (DTPumpStationView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Pump Station - Off", nil);
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed: 0.08 green: 0.49 blue: 0.97 alpha: 1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Running", nil);
        } else if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.75 green:.15 blue:.17 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Alert", nil);
        } /*else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:1 green:.4 blue:0 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Running with Chemical", nil);
        }*/ else if (indexPath.row == 6) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Off", nil);
        } else if (indexPath.row == 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed: 0.08 green: 0.49 blue: 0.97 alpha: 1];
            img.pumpState = DTPumpStateRegulating;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Regulate Pump", nil);
        } else if (indexPath.row == 8) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PumpHelpCell"];
            DTPumpView *img = (DTPumpView *)[cell viewWithTag:1];
            img.color = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
            img.pumpState = DTPumpStateLocked;
            [img setNeedsDisplay];
            UILabel * label = (UILabel *)[cell viewWithTag:2];
            label.text = NSLocalizedString(@"Specific Pump - Locked Out", nil);
        }
    }
    
    // explicitly set the size to make resizing work better
    // but only the first time, or they won't be layed out right after a search
    //if (![sizedIndexPaths containsObject:indexPath]) {
//    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 320, 54);
//    
//    UIView *icon = [cell viewWithTag:1];
//    icon.frame = CGRectMake(10, 
//                            (cell.frame.size.height - icon.frame.size.height) / 2.0, 
//                            icon.frame.size.width, 
//                            icon.frame.size.height);
//    
//    UIView *label = [cell viewWithTag:2];
//    label.frame = CGRectMake(54, 8, 256, 38);
    
    [sizedIndexPaths addObject:indexPath];
    //}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellText = [(UILabel *)[cell viewWithTag:2] text];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    UIFont *labelFont = label.font;
    
    CGFloat cellHeight = 54;
    CGSize textSize = [cellText sizeWithFont:labelFont];
    if (textSize.height > 0) {
        double finalHeight = self.view.frame.size.height;
        double finalWidth = label.bounds.size.width; // 256
        cellHeight = [cellText sizeWithFont:labelFont 
                          constrainedToSize:CGSizeMake(finalWidth, finalHeight) 
                              lineBreakMode:label.lineBreakMode].height;
        // add the padding
        cellHeight += 20;
    }
    
    return cellHeight < 54 ? 54 : cellHeight;
}

- (void)reloadTable
{
    [store.managedObjectContext reset];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[[DTGPIOType class] description]];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"typeDescription" ascending:YES], 
                               nil];
    
    iconController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                            managedObjectContext:store.managedObjectContext 
                                                              sectionNameKeyPath:nil 
                                                                       cacheName:nil];
    NSError *error;
    [iconController performFetch:&error];

    [(UITableView *)self.view reloadData];
}


#pragma mark - Notifications

- (void)configurationUpdate:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        if (self.isViewLoaded) {
            [self reloadTable];
        }
    }];
}

@end
