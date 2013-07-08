//
//  DTPumpDashboardViewController.m
//  FN3
//
//  Created by David Jablonski on 4/11/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPumpDashboardViewController.h"
#import "DTAppDelegate.h"
#import "DTView.h"
#import "DTLinearGradientShader.h"
#import "UIColor+DTColor.h"
#import "UIView+DTCustomViews.h"
#import "DTEditableView.h"
#import "DTSolidShader.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTEquipmentOperation.h"
#import "DTConnection.h"
#import "DTResponse.h"

#import "DTPivotView.h"
#import "DTPumpGaugeView.h"
#import "DTPumpView.h"
#import "DTPumpStationView.h"

#import "DTPersistentStore.h"
#import "DTPumpStation.h"
#import "DTPump.h"
#import "DTConfiguration.h"
#import "DTEquipmentDataField.h"

#import "DTConnectionView.h"
#import "DTPollButton.h"
#import "DTActivityIndicatorView.h"
#import "UIAlertView+DTAlertView.h"

#import "DTAnalytics.h"
#import "FN3ApiStatus.h"

@implementation DTPumpDashboardViewController

@synthesize equipmentId;
@synthesize powerGaugeContainer;
@synthesize powerContainer;
@synthesize pressureGaugeContainer;
@synthesize flowGaugeContainer;
@synthesize pressureContainer;
@synthesize flowContainer;
@synthesize headerView;
@synthesize pollButton;
@synthesize changeStatusButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    store = [[DTPersistentStore alloc] init];
    
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    DTPumpStationView *pumpIcon = [[DTPumpStationView alloc] initWithFrame:CGRectMake(0, 5, 30, 30)];
    pumpIcon.tag = 1;
    pumpIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.navigationItem.titleView addSubview:pumpIcon];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 
                                                                    0, 
                                                                    self.navigationItem.titleView.frame.size.width - 40, 
                                                                    self.navigationItem.titleView.frame.size.height)];
    titleLabel.tag = 2;
    titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.navigationItem.titleView addSubview:titleLabel];
    self.navigationItem.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationItem.titleView.clipsToBounds = YES;
    
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    self.headerView.background = [UIView blackGradientShader];
    self.headerView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    
    self.pressureGaugeContainer.background = [UIView grayGradientShader];
    self.pressureGaugeContainer.roundedCorners = DTViewRoundedCornerTopLeft | DTViewRoundedCornerTopRight;
    self.pressureContainer.background = [UIView blackGradientShader];
    self.pressureContainer.roundedCorners = DTViewRoundedCornerTopRight | DTViewRoundedCornerBottomRight;
    
    self.flowGaugeContainer.background = [UIView grayGradientShader];
    self.flowContainer.background = [UIView blackGradientShader];
    self.flowContainer.roundedCorners = DTViewRoundedCornerTopRight | DTViewRoundedCornerBottomRight;
    
    self.powerGaugeContainer.background = [UIView grayGradientShader];
    self.powerGaugeContainer.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    self.powerContainer.background = [UIView blackGradientShader];
    self.powerContainer.roundedCorners = DTViewRoundedCornerTopRight | DTViewRoundedCornerBottomRight;
    
    [self.pollButton setPollCompleteTarget:self selector:@selector(onPollComplete:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentUpdate:) 
                                                 name:DTEquipmentDetailUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentDelete:) 
                                                 name:DTEquipmentDelete
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(configurationUpdate:) 
                                                 name:DTConfigurationUpdate
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.pollButton.enabled = !self.isEditing;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // refresh the data
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.pollButton stop];
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
    pumpStation = nil;
    
    pressureGaugeContainer = nil;
    flowGaugeContainer = nil;
    
    pressureContainer = nil;
    flowContainer = nil;
    headerView = nil;
    pollButton = nil;
    changeStatusButton = nil;
    powerGaugeContainer = nil;
    powerContainer = nil;
    
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

#pragma mark - Notifications

- (void)refreshData
{
    if (!isRunningRefresh && !isUpdatingStatus && !self.pollButton.isPolling) {
        isRunningRefresh = YES;
        
        NSOperation *op = [[DTEquipmentOperation alloc] initWithEquipmentId:pumpStation.identifier];
        op.completionBlock = ^(void) {
            isRunningRefresh = NO;
        };
        [[NSOperationQueue networkQueue] addNetworkOperation:op];
    }
}

- (void)configurationUpdate:(NSNotification *)notification
{
    if (!isUpdatingStatus) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            if (self.isViewLoaded) {
                [self initializeFromConfiguration];
            }
        }];
    }
}

- (void)equipmentUpdate:(NSNotification *)notification
{
    if ([notification.object containsObject:self.equipmentId] && !isUpdatingStatus && !self.pollButton.isPolling) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            if (self.isViewLoaded) {
                [(UITableView *)self.view reloadData];
            }
        }];
    }
}

- (void)equipmentDelete:(NSNotification *)notification
{
    if ([notification.object containsObject:self.equipmentId]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}

- (IBAction)changeStatus:(id)sender
{
    if (![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    NSString *message;
    NSString *action;
    if ([pumpStation.enabled boolValue]) {
        message = NSLocalizedString(@"Disable this device?", nil);
        action = NSLocalizedString(@"Disable", nil);
    } else {
        message = NSLocalizedString(@"Enable this device?", nil);
        action = NSLocalizedString(@"Enable", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                          otherButtonTitles:action, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        DTActivityIndicatorView *activity = [[DTActivityIndicatorView alloc] init];
        [activity show];
        
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
            isUpdatingStatus = YES;
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:pumpStation.identifier forKey:@"id"];
            [params setObject:[NSNumber numberWithBool:![pumpStation.enabled boolValue]] 
                       forKey:@"enabled"];
            
            DTResponse *response = [DTConnection postTo:FN3APIEquipmentOptions parameters:params];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                if (response.isSuccess) {
                    self.changeStatusButton.enabled = NO;
                    [self.pollButton pollEquipmentId:pumpStation.identifier functionId:[response.data objectForKey:@"function_id"]];
                } else {
                    if (response.isAuthenticationError) {
                        [[UIAlertView alertViewForNotAuthenticated] show];
                        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                    } else {
                        [[UIAlertView alertViewForResponse:response 
                                            defaultMessage:NSLocalizedString(@"There was an error saving device parameters.", nil)] show];
                    }
                }
            }];
        }];
        op.completionBlock = ^(void){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [activity dismiss];
                isUpdatingStatus = NO;
            }];
        };
        [[NSOperationQueue networkQueue] addNetworkOperation:op];
    }
}

- (IBAction)poll:(id)sender
{
    [self.pollButton pollEquipmentId:pumpStation.identifier];
    self.changeStatusButton.enabled = NO;
}

- (void)onPollComplete:(BOOL)success
{
    self.changeStatusButton.enabled = YES;
    
    [self refreshData];
    
    if (!success) {
        [(UITableView *)self.view reloadData];
        
        UILabel *label = (UILabel *)[self.headerView viewWithTag:2];
        label.textColor = [UIColor redColor];
        label.text = NSLocalizedString(@"Poll failed", nil);
    }
}

- (void)initializeFromEquipment
{
    pumpStation = nil;
    [store.managedObjectContext reset];
    pumpStation = (DTPumpStation *)[DTEquipment equipmentWithId:equipmentId inContext:store.managedObjectContext];
    
    [(DTPumpGaugeView *) [self.pressureGaugeContainer viewWithTag:1] configureFromGauge:pumpStation.pressureGauge];
    [(DTPumpGaugeView *) [self.flowGaugeContainer viewWithTag:1] configureFromGauge:pumpStation.flowGauge];
    
    UIView *tableHeader = [(UITableView *)self.view tableHeaderView];
    if (pumpStation.powerGauge) {
        self.powerGaugeContainer.hidden = self.powerContainer.hidden = NO;
        self.powerGaugeContainer.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
        [self.powerGaugeContainer setNeedsDisplay];
        
        self.flowGaugeContainer.roundedCorners = DTViewRoundedCornerNone;
        [self.flowGaugeContainer setNeedsDisplay];
        
        tableHeader.frame = CGRectMake(tableHeader.frame.origin.x, 
                                       tableHeader.frame.origin.y, 
                                       tableHeader.frame.size.width, 
                                       self.powerGaugeContainer.frame.origin.y + self.powerGaugeContainer.frame.size.height + 10);
        // set the header on the table so it knows the size changed
        [(UITableView *)self.view setTableHeaderView:tableHeader];
        
        [(DTPumpGaugeView *) [self.powerGaugeContainer viewWithTag:1] configureFromGauge:pumpStation.powerGauge];
    } else {
        self.powerGaugeContainer.hidden = self.powerContainer.hidden = YES;
        self.flowGaugeContainer.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
        [self.flowGaugeContainer setNeedsDisplay];
        
        tableHeader.frame = CGRectMake(tableHeader.frame.origin.x, 
                                       tableHeader.frame.origin.y, 
                                       tableHeader.frame.size.width, 
                                       self.flowGaugeContainer.frame.origin.y + self.flowGaugeContainer.frame.size.height + 10);
        // set the header on the table so it knows the size changed
        [(UITableView *)self.view setTableHeaderView:tableHeader];
    }
    
    [self initializeFromConfiguration];
    
    DTPumpView *pumpIcon = (DTPumpView *)[self.navigationItem.titleView viewWithTag:1];
    [pumpIcon configureFromEquipment:pumpStation];
    UILabel *titleLabel = (UILabel *)[self.navigationItem.titleView viewWithTag:2];
    titleLabel.text = pumpStation.title;
    
    CGSize size = [titleLabel sizeThatFits:CGSizeMake(0, 0)];
    self.navigationItem.titleView.frame = CGRectMake(self.navigationItem.titleView.frame.origin.x, 
                                                     self.navigationItem.titleView.frame.origin.y, 
                                                     size.width + titleLabel.frame.origin.x + 5, 
                                                     self.navigationItem.titleView.frame.size.height);
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 
                                  titleLabel.frame.origin.y, 
                                  size.width, 
                                  self.navigationItem.titleView.frame.size.height);
    
    
    [(DTConnectionView *)[self.headerView viewWithTag:1] setCommStatus:pumpStation.commStatus];
    
    if (!self.pollButton.isInPollError) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateStyle = format.timeStyle =  NSDateFormatterShortStyle;
        [(UILabel *)[self.headerView viewWithTag:2] setText:[format stringFromDate:pumpStation.lastUpdated]];
        [(UILabel *)[self.headerView viewWithTag:2] setTextColor:[UIColor whiteColor]];
    }
    
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    numberFormat.maximumFractionDigits = 2;
    numberFormat.minimumFractionDigits = 0;
    [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    
    DTEquipmentDataField *pressure = pumpStation.pressure;
    [(UILabel *)[self.pressureContainer viewWithTag:1] setText:[numberFormat stringFromNumber:pressure.numericValue]];
    [(UILabel *)[self.pressureContainer viewWithTag:2] setText:pressure.uom];
    
    DTEquipmentDataField *flow = pumpStation.flow;
    [(UILabel *)[self.flowContainer viewWithTag:1] setText:[numberFormat stringFromNumber:flow.numericValue]];
    [(UILabel *)[self.flowContainer viewWithTag:2] setText:flow.uom];
    
    DTEquipmentDataField *power = pumpStation.power;
    [(UILabel *)[self.powerContainer viewWithTag:1] setText:[numberFormat stringFromNumber:power.numericValue]];
    [(UILabel *)[self.powerContainer viewWithTag:2] setText:power.uom];
}

- (void)initializeFromConfiguration
{
    if (pumpStation) {
        DTConfiguration *config = [DTConfiguration configurationNamed:pumpStation.driver 
                                                            inContext:store.managedObjectContext];
        if (config && [config.availableFieldNames containsObject:@"enabled"] && [FN3ApiStatus instance].isActive) {
            if (pumpStation.enabled.boolValue) {
                self.changeStatusButton.title = NSLocalizedString(@"Disable", nil);
            } else {
                self.changeStatusButton.title = NSLocalizedString(@"Enable", nil);
            }
            
            if (!self.navigationItem.rightBarButtonItem) {
                [self.navigationItem setRightBarButtonItem:self.changeStatusButton animated:YES];
            }
        } else {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self initializeFromEquipment];
    
    return pumpStation.pumps.count == 0 ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;
        case 1: return pumpStation.pumps.count;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
        numberFormat.maximumFractionDigits = 0;
        [numberFormat setNumberStyle:NSNumberFormatterDecimalStyle];
        
        
        UITableViewCell *cell;
        
        if (pumpStation.dashboardFieldName) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeMeasurementsCell"];
            
            DTEquipmentDataField *field = [pumpStation fieldWithName:pumpStation.dashboardFieldName];
            numberFormat.maximumFractionDigits = 2;
            [(UILabel *)[cell viewWithTag:1] setText:[numberFormat stringFromNumber:field.numericValue]];
            [(UILabel *)[cell viewWithTag:2] setText:field.uom];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TwoMeasurementsCell"];
        }
        
        DTEquipmentDataField *currentDemand = pumpStation.currentDemand;
        numberFormat.maximumFractionDigits = 0;
        [(UILabel *)[cell viewWithTag:3] setText:[numberFormat stringFromNumber:currentDemand.numericValue]];
        [(UILabel *)[cell viewWithTag:4] setText:currentDemand.uom];
        
        DTEquipmentDataField *remainingCapacity = pumpStation.remainingCapacity;
        [(UILabel *)[cell viewWithTag:5] setText:[numberFormat stringFromNumber:remainingCapacity.numericValue]];
        [(UILabel *)[cell viewWithTag:6] setText:remainingCapacity.uom];
        
        return cell;
    } else {
        DTPump *pump = [pumpStation pumpWithOrder:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PumpCell"];

        [(DTPumpView *)[cell viewWithTag:1] configureFromPump:pump];
        [(UILabel *)[cell viewWithTag:2] setText:pump.name];
        [(UILabel *)[cell viewWithTag:3] setText:NSLocalizedString([pump.enabled boolValue] ? @"Enabled" : @"Disabled", nil)];
        [(UILabel *)[cell viewWithTag:4] setText:pump.hoa];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1: return NSLocalizedString(@"Pumps", nil);
        default: return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *header = [UIView tableHeaderViewWithTitle:nil];
        header.frame = CGRectMake(header.frame.origin.x,
                                  header.frame.origin.y,
                                  tableView.frame.size.width,
                                  44);
        
        UILabel *col1 = (UILabel *)[header viewWithTag:1];
        col1.textAlignment = UITextAlignmentCenter;
        col1.numberOfLines = 2;
        col1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        col1.adjustsFontSizeToFitWidth = YES;
        
        CGSize size;
        if (pumpStation.dashboardFieldName) {
            col1.text = NSLocalizedString(pumpStation.dashboardFieldName, nil);
            col1.frame = CGRectMake(5, 4, (col1.superview.frame.size.width - 20) / 3.0, 32);
            size = col1.frame.size;
        } else {
            col1.frame = CGRectMake(0, 4, 0, 0);
            size = CGSizeMake((col1.superview.frame.size.width - 15) / 2.0f, 32);
        }
        
        UILabel *col2 = [[UILabel alloc] initWithFrame:CGRectMake(col1.frame.origin.x + col1.frame.size.width + 5,
                                                                  col1.frame.origin.y,
                                                                  size.width,
                                                                  size.height)];
        col2.backgroundColor = col1.backgroundColor;
        col2.font = col1.font;
        col2.textAlignment = col1.textAlignment;
        col2.textColor = col1.textColor;
        col2.text = NSLocalizedString(@"Current Demand", nil);
        col2.numberOfLines = col1.numberOfLines;
        col2.adjustsFontSizeToFitWidth = col1.adjustsFontSizeToFitWidth;
        col2.autoresizingMask = col1.autoresizingMask;
        [col1.superview addSubview:col2];
        
        UILabel *col3 = [[UILabel alloc] initWithFrame:CGRectMake(col2.frame.origin.x + col2.frame.size.width + 5,
                                                                  col2.frame.origin.y,
                                                                  size.width,
                                                                  size.height)];
        col3.backgroundColor = col1.backgroundColor;
        col3.font = col1.font;
        col3.textAlignment = col1.textAlignment;
        col3.textColor = col1.textColor;
        col3.numberOfLines = col1.numberOfLines;
        col3.autoresizingMask = col1.autoresizingMask;
        col3.text = NSLocalizedString(@"Remaining Capacity", nil);
        [col1.superview addSubview:col3];
        
        return header;
    } else {
        return [UIView tableHeaderViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 44 : -1;
}

@end
