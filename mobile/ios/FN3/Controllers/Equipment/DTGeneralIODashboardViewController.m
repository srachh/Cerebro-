//
//  DTGeneralIOViewController.m
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTGeneralIODashboardViewController.h"

#import "DTAppDelegate.h"
#import "DTPersistentStore.h"
#import "DTGeneralIO.h"
#import "DTEquipmentDataField.h"
#import "DTConfiguration.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTEquipmentOperation.h"
#import "DTConnection.h"
#import "DTResponse.h"

#import "DTActivityIndicatorView.h"
#import "DTView.h"
#import "DTLinearGradientShader.h"
#import "DTSolidShader.h"
#import "DTConnectionView.h"
#import "DTEditableView.h"
#import "DTPollButton.h"

#import "UIView+DTCustomViews.h"
#import "UIColor+DTColor.h"
#import "UIAlertView+DTAlertView.h"

#import "DTAnalytics.h"
#import "FN3ApiStatus.h"


@implementation DTGeneralIODashboardViewController
@synthesize headerView;
@synthesize pollButton;
@synthesize changeStatusButton;

@synthesize equipmentId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    store = [[DTPersistentStore alloc] init];
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    self.navigationItem.titleView = [UIView equipmentNavigationTitleView];
    
    // set up the header view
    self.headerView.background = [UIView blackGradientShader];
    self.headerView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    
    // set up the refresh button
    [self.pollButton setPollCompleteTarget:self selector:@selector(onPollComplete:)];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipmentUpdate:) 
                                                 name:DTEquipmentDetailUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(equipentDelete:) 
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
    
    headerView = nil;
    pollButton = nil;
    changeStatusButton = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notifications

- (void)refreshData
{
    if (!isRunningRefresh && !isUpdatingStatus && !self.pollButton.isPolling) {
        isRunningRefresh = YES;
        
        NSOperation *op = [[DTEquipmentOperation alloc] initWithEquipmentId:generalIO.identifier];
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

- (void)equipentDelete:(NSNotification *)notification
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
    if ([generalIO.enabled boolValue]) {
        message = NSLocalizedString(@"Turn off this device?", nil);
        action = NSLocalizedString(@"Turn Off", nil);
    } else {
        message = NSLocalizedString(@"Turn on this device?", nil);
        action = NSLocalizedString(@"Turn On", nil);
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
            [params setObject:generalIO.identifier forKey:@"id"];
            [params setObject:[NSNumber numberWithBool:![generalIO.enabled boolValue]] 
                       forKey:@"enabled"];
            
            DTResponse *response = [DTConnection postTo:FN3APIEquipmentOptions parameters:params];
            if (response.isSuccess) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    [self.pollButton pollEquipmentId:generalIO.identifier functionId:[response.data objectForKey:@"function_id"]];
                    self.changeStatusButton.enabled = NO;
                }];
            } else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    if (response.isAuthenticationError) {
                        [[UIAlertView alertViewForNotAuthenticated] show];
                        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                    } else {
                        [[UIAlertView alertViewForResponse:response 
                                            defaultMessage:NSLocalizedString(@"There was an error saving device parameters.", nil)] show];
                    }
                }];
            }
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
    [self.pollButton pollEquipmentId:generalIO.identifier];
    self.changeStatusButton.enabled = NO;
}

- (void)onPollComplete:(BOOL)success
{
    self.changeStatusButton.enabled = YES;
    
    [self refreshData];
    
    if (!success) {
        UILabel *label = (UILabel *)[self.headerView viewWithTag:2];
        label.textColor = [UIColor redColor];
        label.text = NSLocalizedString(@"Poll failed", nil);
    }
}

- (void)initializeFromEquipment
{
    generalIO = nil;
    [store.managedObjectContext reset];
    generalIO = (DTGeneralIO *) [DTGeneralIO equipmentWithId:equipmentId 
                                                   inContext:store.managedObjectContext];
    fields = [generalIO.dataFields.allObjects sortedArrayUsingComparator:^NSComparisonResult(DTEquipmentDataField *io1, DTEquipmentDataField *io2) {
        return [io1.order compare:io2.order];
    }];
    
    UILabel *title = (UILabel *)self.navigationItem.titleView;
    title.text = generalIO.title;
    CGSize size = [title sizeThatFits:CGSizeMake(0, 0)];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, size.width, size.height);
    
    [self initializeFromConfiguration];
    
    if (!self.pollButton.isInPollError) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateStyle = format.timeStyle = NSDateFormatterShortStyle;
        [(UILabel *)[self.headerView viewWithTag:2] setText:[format stringFromDate:generalIO.lastUpdated]];
        [(UILabel *)[self.headerView viewWithTag:2] setTextColor:[UIColor whiteColor]];
    }
    
    [(DTConnectionView *)[self.headerView viewWithTag:1] setCommStatus:generalIO.commStatus];
}

- (void)initializeFromConfiguration
{
    if (generalIO) {
        DTConfiguration *config = [DTConfiguration configurationNamed:generalIO.driver 
                                                            inContext:store.managedObjectContext];
        if (config && [config.availableFieldNames containsObject:@"enabled"] && [FN3ApiStatus instance].isActive) {
            self.changeStatusButton.title = NSLocalizedString([generalIO.enabled boolValue] ? @"Turn Off" : @"Turn On", nil);
            
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fields.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTEquipmentDataField *data = [fields objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataCell"];
    [(UILabel *)[cell viewWithTag:1] setText:data.name];
    if (!data.value) {
        [(UILabel *)[cell viewWithTag:2] setText:@""];
    } else if (data.uom) {
        [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%@ %@", data.value, data.uom]];
    } else {
        [(UILabel *)[cell viewWithTag:2] setText:data.value];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView tableHeaderViewWithTitle:generalIO.subtitle];
    
    UIView *label = [view viewWithTag:1];
    UIView *parent = label.superview;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:generalIO.icon];
    imageView.frame = CGRectMake(label.frame.origin.x, 
                                 9, 
                                 32, 
                                 32);
    [parent addSubview:imageView];
    
    label.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + label.frame.origin.x, 
                             label.frame.origin.y, 
                             label.frame.size.width - imageView.frame.origin.x - imageView.frame.size.width, 
                             label.frame.size.height);
    
    return view;
}

@end
