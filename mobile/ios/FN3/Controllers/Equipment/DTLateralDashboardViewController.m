//
//  DTLateralDashboardViewController.m
//  FN3
//
//  Created by David Jablonski on 4/16/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTLateralDashboardViewController.h"

#import "DTAppDelegate.h"

#import "DTView.h"
#import "DTLateralView.h"
#import "UIColor+DTColor.h"
#import "DTEditableView.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTConnectionView.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTEquipmentOperation.h"

#import "DTPersistentStore.h"
#import "DTLateral.h"
#import "DTConfiguration.h"
#import "DTPlan.h"
#import "DTEquipmentDataField.h"
#import "DTEquipmentAccessoryField.h"
#import "DTEquipmentHistory.h"
#import "DTEquipmentHistoryParser.h"
#import "DTHistoryDetailViewController.h"

#import "DTPollButton.h"

#import "DTSolidShader.h"
#import "DTLinearGradientShader.h"
#import "DTSimpleBorder.h"

#import "DTNumberField.h"
#import "DTDirectionField.h"
#import "DTToggleField.h"
#import "DTKeypadView.h"
#import "DTServiceStopField.h"
#import "DTSpeedDepthField.h"

#import "DTActivityIndicatorView.h"
#import "UIView+DTCustomViews.h"
#import "UIAlertView+DTAlertView.h"

#import "DTAnalytics.h"
#import "FN3ApiStatus.h"


@implementation DTLateralDashboardViewController

@synthesize equipmentId;

@synthesize headerView;
@synthesize planView;
@synthesize pollButton;
@synthesize editButton;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize statusSummaryView;
@synthesize currentPositionView;
@synthesize durationView;
@synthesize directionView;
@synthesize speedDepthView;
@synthesize waterView;
@synthesize psiView;
@synthesize gpmView;
@synthesize serviceStopView;
@synthesize controlsHeader;
@synthesize bottomRightView;
@synthesize accessoryTitleView;
@synthesize accessoryOneView;
@synthesize accessoryTwoView;
@synthesize chemigationView;
@synthesize voltageTempView;
@synthesize voltageTempTitleView;

- (UIView *)inputNavbarView:(NSString *)title
{
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    CGSize navSize = [navBar sizeThatFits:CGSizeMake(0, 0)];
    navBar.frame = CGRectMake(0, 0, navSize.width, navSize.height);
    navBar.translucent = YES;
    navBar.tintColor = [UIColor colorWithRed:.31 green:.34 blue:.39 alpha:1.0];
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                              style:UIBarButtonItemStylePlain 
                                                             target:self 
                                                             action:@selector(hideInputView)];
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                               style:UIBarButtonItemStylePlain 
                                                              target:self 
                                                              action:@selector(nextInputView)];
    item.title = title;
    navBar.items = [NSArray arrayWithObject:item];
    
    return navBar;
}

#pragma mark - Polling

- (IBAction)poll:(id)sender
{
    [self.pollButton pollEquipmentId:self.equipmentId];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)onPollComplete:(BOOL)success
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self refreshData];
    
    if (!success) {
        [(UITableView *)self.view reloadData];
        
        UILabel *label = (UILabel *)[self.headerView viewWithTag:2];
        label.textColor = [UIColor redColor];
        label.text = NSLocalizedString(@"Poll failed", nil);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [UIView equipmentNavigationTitleView];
    
    [(UITableView *)self.view setBackgroundView:nil];
    
    self.saveButton.tintColor = [UIColor barButtonSaveItemTintColor];
    [self.saveButton setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]
                                   forState:UIControlStateNormal];
    
    // set up the header view
    self.headerView.background = [UIView blackGradientShader];
    self.headerView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    
    // setup the lateral view
    leftView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerTopLeft;
    leftView.background = [UIView blackGradientShader];
    
    // set up the poll button
    [self.pollButton setPollCompleteTarget:self selector:@selector(onPollComplete:)];
    
    // set up the right view
    statusSummaryView.background = currentPositionView.background = durationView.background = [UIView grayGradientShader];
    statusSummaryView.border = currentPositionView.border = durationView.border = [UIView grayBorder];
    durationView.roundedCorners = DTViewRoundedCornerBottomRight;
    statusSummaryView.roundedCorners = DTViewRoundedCornerTopRight;
    
    // set up the plan view
    self.planView.roundedCorners = DTViewRoundedCornerTopLeft | DTViewRoundedCornerTopRight;
    self.planView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Select plan", nil)];
    self.planView.delegate = self;
    self.planView.backgroundView.background = [UIView grayGradientShader];
    self.planView.backgroundView.border = [UIView grayBorder];
    
    self.psiView.background = self.gpmView.background = [UIView grayGradientShader];
    self.psiView.border = self.gpmView.border = [UIView grayBorder];
    self.gpmView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    
    self.directionView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Select direction", nil)];
    self.directionView.backgroundView.background = [UIView blackGradientShader];
    self.directionView.isLateral = YES;
    
    self.waterView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Water", nil)];
    self.waterView.backgroundView.background = [UIView blackGradientShader];
    self.waterView.name = @"waterCheckbox";
    self.waterView.title = NSLocalizedString(@"Water", @"water toggle title");
    self.waterView.onImage = [UIImage imageNamed:@"flow_selected.png"];
    self.waterView.offImage = [UIImage imageNamed:@"flow.png"];
    self.waterView.toggleImage = [UIImage imageNamed:@"flow_black.png"];
    [self.waterView setInputChangeTarget:self selector:@selector(onWaterChange:)];
    
    self.speedDepthView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Speed %", nil)];
    self.speedDepthView.backgroundView.background = [UIView grayGradientShader];
    self.speedDepthView.backgroundView.border = [UIView grayBorder];
    self.speedDepthView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    self.speedDepthView.delegate = self;
    
    self.controlsHeader.background = [UIView blackGradientShader];
    
    self.serviceStopView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Stop position", nil)];
    self.serviceStopView.backgroundView.background = [UIView grayGradientShader];
    self.serviceStopView.backgroundView.border = [UIView grayBorder];
    [self.serviceStopView setDigits:5];
    [self.serviceStopView setDecimalPlaces:2];
    self.serviceStopView.delegate = self;
    
    self.bottomRightView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    self.bottomRightView.background = [UIView grayGradientShader];
    self.bottomRightView.border = [UIView grayBorder];
    
    // set up accessory view
    self.accessoryTitleView.background = self.accessoryOneView.backgroundView.background = self.accessoryTwoView.backgroundView.background = self.chemigationView.backgroundView.background = [UIView blackGradientShader];
    self.accessoryTitleView.roundedCorners = DTViewRoundedCornerAll;
    self.chemigationView.roundedCorners =  self.accessoryOneView.roundedCorners = self.accessoryTwoView.roundedCorners = DTViewRoundedCornerBottomLeft | DTViewRoundedCornerBottomRight;
    
    self.accessoriesLabel.text = NSLocalizedString(@"Accessories", @"accessories toggle title");
    self.voltageLabel.text = NSLocalizedString(@"Voltage", @"voltage toggle title");
    self.temperatureLabel.text = NSLocalizedString(@"Temperature", @"temperature toggle title");
    
    self.chemigationView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Chemigation", nil)];
    //   self.chemigationView.backgroundView.background = [UIView blackGradientShader];
    self.chemigationView.name = @"chemicalCheckbox";
    self.chemigationView.title = NSLocalizedString(@"Chemigation", @"chemigation toggle title");
    self.chemigationView.onImage = [UIImage imageNamed:@"chemigation_selected.png"];
    self.chemigationView.offImage = [UIImage imageNamed:@"chemigation.png"];
    self.chemigationView.toggleImage = [UIImage imageNamed:@"chemigation_black.png"];
    self.chemigationView.delegate = self;
    
    self.accessoryOneView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Accessory One", nil)];
    self.accessoryOneView.backgroundView.background = [UIView blackGradientShader];
    self.accessoryOneView.name = @"acc1Checkbox";
    self.accessoryOneView.title = NSLocalizedString(@"AccessoryOne", @"accessory one toggle title");
    self.accessoryOneView.onImage = [UIImage imageNamed:@"accessory_one_selected.png"];
    self.accessoryOneView.offImage = [UIImage imageNamed:@"accessory_one.png"];
    self.accessoryOneView.toggleImage = [UIImage imageNamed:@"accessory_one_black.png"];
    self.accessoryOneView.delegate = self;
    
    self.accessoryTwoView.customInputAccessoryView = [self inputNavbarView:NSLocalizedString(@"Accessory Two", nil)];
    self.accessoryTwoView.backgroundView.background = [UIView blackGradientShader];
    self.accessoryTwoView.name = @"acc2Checkbox";
    self.accessoryTwoView.title = NSLocalizedString(@"AccessoryTwo", @"accessory two toggle title");
    self.accessoryTwoView.onImage = [UIImage imageNamed:@"accessory_two_selected.png"];
    self.accessoryTwoView.offImage = [UIImage imageNamed:@"accessory_two.png"];
    self.accessoryTwoView.toggleImage = [UIImage imageNamed:@"accessory_two_black.png"];
    self.accessoryTwoView.delegate = self;
    
    // set up voltage/temperature View
    self.voltageTempTitleView.background = [UIView blackGradientShader];
    self.voltageTempView.background = [UIView grayGradientShader];
    self.voltageTempTitleView.roundedCorners = DTViewRoundedCornerTopLeft | DTViewRoundedCornerTopRight;
    self.voltageTempView.roundedCorners = DTViewRoundedCornerAll;
    
    editableFields = [NSArray arrayWithObjects:
                      self.planView, 
                      self.directionView,
                      self.waterView,
                      self.speedDepthView, 
                      self.serviceStopView,
                      self.chemigationView,
                      self.accessoryOneView,
                      self.accessoryTwoView,
                      nil];
    
    store = [[DTPersistentStore alloc] init];
    
    historyTableSize = 0;
    historyRecordsRequestSize = 5;
    
    if (!hasLoadedViewBefore) {
        hasLoadedViewBefore = YES;
        isDoingInitialFetch = YES;
        hasMoreHistory = YES;
        
        /*
         NSSet *historyData;
         historyData = [DTEquipmentHistory equipmentHistoryInContext:store.managedObjectContext];
         for (DTEquipmentHistory *history in historyData) {
         [store.managedObjectContext deleteObject:history];
         }
         [store save];
        */

        [self fetchNextPageForHistoryRecords:self.equipmentId startId:0];
    } else {
        [self reloadTable];
        [(UITableView *)self.view setContentOffset:CGPointMake(0, lastContentOffset) animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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

- (void)planSelectField:(DTPlanSelectField *)planField selectedPlan:(DTPlan *)plan
{
    NSSet *planEditableFields = plan.editableFieldNames;
    NSSet *planAvailableFields = plan.configuration.availableFieldNames;
    for (DTField* field in editableFields) {
        [field setEditableFields:planEditableFields
                 availableFields:planAvailableFields];
        
        if ((field.permissions & DTFieldPermissionEditable) != DTFieldPermissionEditable) {
            if (field.state == DTEditableViewStateEditing) {
                [field revert];
                [field setEditing:NO animated:YES];
            }
        } else {
            if (field.state != DTEditableViewStateEditing) {
                [field setEditing:YES animated:YES];
            }
        }
    }
}

- (BOOL)speedDepthFieldShouldEndEditing:(DTSpeedDepthField *)speedDepthField
{
    NSString *msgFieldName = nil;
    NSString *msg = nil;
    
    if (speedDepthField.isValid) {
        return YES;
    } else {
        
        if (speedDepthField.isSpeedFieldSelected) {
            msg = NSLocalizedString(@"Speed value is invalid.", nil);
        } else {
            msgFieldName = speedDepthField.depthTitle;
            msg = NSLocalizedString(@"Depth to apply value is invalid.", nil);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msg
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (BOOL)serviceStopFieldShouldEndEditing:(DTServiceStopField *)serviceStopField
{
    if (serviceStopField.isValid) {
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Stop position value is invalid.", nil)
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
}

- (BOOL)toggleFieldShouldEndEditing:(DTToggleField *)toggleField
{
    if ([requiresWaterFieldNames containsObject:[toggleField name]]) {
        if (!self.waterView.on && toggleField.on) {
            NSString *msg = nil;
            
            if (toggleField.name == @"chemicalCheckbox") {
                msg = NSLocalizedString(@"Water must be turned on before Chemigation can be turned on", nil);
            } else if (toggleField.name == @"acc1Checkbox") {
                msg = NSLocalizedString(@"Water must be turned on before Accessory 1 can be turned on", nil);
            } else if (toggleField.name == @"acc2Checkbox") {
                msg = NSLocalizedString(@"Water must be turned on before Accessory 2 can be turned on", nil);
            } else {
                msg = NSLocalizedString(@"An Error occurred", nil);
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)hideInputView
{
    for (UIView *view in editableFields) {
        [view resignFirstResponder];
    }
}

- (void)nextInputView
{
    UIView *firstResponder = nil;
    for (UIView *view in editableFields) {
        if (view.isFirstResponder) {
            firstResponder = view;
            break;
        }
    }
    
    BOOL foundCurrentView = NO;
    for (DTField *field in editableFields) {
        if (foundCurrentView && field.state == DTEditableViewStateEditing && [field canBecomeFirstResponder]) {
            [field becomeFirstResponder];
            return;
        } else if (field == firstResponder) {
            foundCurrentView = YES;
        }
    }
    [firstResponder resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [leftView addSubview:equipmentView];
    
    [self.pollButton setEnabled:!self.editing];
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
    
    lastContentOffset = [(UITableView *)self.view contentOffset].y;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.pollButton stop];
    
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    lateral = nil;
    resultsController = nil;
    store = nil;
    
    headerView = nil;
    
    leftView = nil;
    lateralView = nil;
    editableFields = nil;
    
    editButton = nil;
    saveButton = nil;
    cancelButton = nil;
    directionView = nil;
    speedDepthView = nil;
    waterView = nil;
    psiView = nil;
    gpmView = nil;
    serviceStopView = nil;
    bottomRightView = nil;
    statusSummaryView = nil;
    currentPositionView = nil;
    durationView = nil;
    planView = nil;
    
    pollButton = nil;
    controlsHeader = nil;
    
    [self setChemigationView:nil];
    [self setAccessoryOneView:nil];
    [self setAccessoryTwoView:nil];
    [self setVoltageTempTitleView:nil];
    [self setVoltageTempView:nil];
    [self setAccessoryTitleView:nil];
    [self setTempValueView:nil];
    [self setTempTypeView:nil];
    [self setVoltageValueView:nil];
    [self setVoltageTypeView:nil];
    [self setTemperatureLabel:nil];
    [self setVoltageLabel:nil];
    [self setAccessoriesLabel:nil];

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

#pragma mark - History methods

- (void)initialFetchCompleted
{
    isDoingInitialFetch = NO;
}

- (void)fetchNextPage
{
    if (!isFetchingData && hasMoreHistory) {
        isFetchingData = YES;
        
        id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
        DTEquipmentHistory *h = [section objects].lastObject;
        
        [self fetchNextPageForHistoryRecords:self.equipmentId startId:h.eventId];
    }
}

- (void)reloadTable
{

    [store.managedObjectContext reset];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[[DTEquipmentHistory class] description]];
    request.predicate = [NSPredicate predicateWithFormat:@"order < %i", historyTableSize];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES], 
                               nil];
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                            managedObjectContext:store.managedObjectContext 
                                                              sectionNameKeyPath:nil 
                                                                       cacheName:nil];
    NSError *error;
    [resultsController performFetch:&error];
    
    if (totalHistoryRecordsRemaining == 0) {
        hasMoreHistory = NO;
    } else {
        hasMoreHistory = YES;
    }
    
    [(UITableView *)self.view reloadData];
}

- (void)fetchNextPageForHistoryRecords:(NSNumber *) equipId startId:(NSNumber *) startId
{
    if (hasMoreHistory) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:equipId
                                                                         forKey:@"id"];
        
        NSNumber *numRecs = [[NSNumber alloc] initWithInt:historyRecordsRequestSize];
        
        [params setValue:numRecs forKey:@"numRecords"];
        
        if (startId.intValue > 0) {
            [params setValue:startId forKey:@"startId"];
        }
        
        [[NSOperationQueue networkQueue] addOperationWithBlock:^(void){
            DTResponse *listResponse = [DTConnection postTo:FN3APIEquipmentHistory parameters:params];
            if (listResponse.isSuccess) {
                NSOperation *op = [[DTEquipmentHistoryParser alloc] initWithListResponse:listResponse.data startIndex:historyTableSize];
                op.completionBlock = ^(void){
                    isFetchingData = NO;
                    if (startId.intValue == 0) {
                        [self initialFetchCompleted];
                    }
                    NSArray *historyRecords = [listResponse.data objectForKey:@"records"];
                    historyTableSize += historyRecords.count;
                    
                    if (historyRecords.count == 0) {
                        totalHistoryRecordsRemaining = 0;
                    } else {
                        totalHistoryRecordsRemaining = [[listResponse.data objectForKey:@"total"] intValue];
                    }
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        [self reloadTable];
                    }];
                };
                [[NSOperationQueue parserQueue] addOperation:op];
            }
        }];
    }
}

#pragma mark - Notifications

- (void)onWaterChange:(DTToggleField *)field
{
    self.speedDepthView.isWaterOn = field.on;
    
    if (!field.on) {
        if ([requiresWaterFieldNames containsObject:[self.chemigationView name]]) {
            self.chemigationView.on = field.on;
        }
        
        if ([requiresWaterFieldNames containsObject:[self.accessoryOneView name]]) {
            self.accessoryOneView.on = field.on;
        }
        
        if ([requiresWaterFieldNames containsObject:[self.accessoryTwoView name]]) {
            self.accessoryTwoView.on = field.on;
        }
    }
}

- (void)refreshData
{
    if (!isRunningRefresh && !self.isEditing && !self.pollButton.isPolling) {
        isRunningRefresh = YES;
        
        NSOperation *op = [[DTEquipmentOperation alloc] initWithEquipmentId:self.equipmentId];
        op.completionBlock = ^(void) {
            isRunningRefresh = NO;
        };
        [[NSOperationQueue networkQueue] addNetworkOperation:op];
    }
}

- (void)configurationUpdate:(NSNotification *)notification
{
    if (!self.isEditing) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            if (self.isViewLoaded) {
                [self reloadTable];
            }
        }];
    }
}

- (void)equipmentUpdate:(NSNotification *)notification
{
    if ([notification.object containsObject:self.equipmentId] && !self.isEditing && !self.pollButton.isPolling) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            if (self.isViewLoaded) {
                [self reloadTable];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    for (UIView *view in editableFields) {
        if (view.isFirstResponder) {
            CGPoint point = [self.view convertPoint:view.frame.origin fromView:view.superview];
            [(UIScrollView *)self.view setContentOffset:CGPointMake(0, point.y - 10)
                                               animated:YES];
            break;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }];
//    [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0)
//                                       animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing == self.isEditing) {
        return;
    } else if (editing && ![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setRightBarButtonItem:editing ? saveButton : editButton animated:animated];
    [self.navigationItem setLeftBarButtonItem:editing ? cancelButton : nil animated:animated];
    
    [self.pollButton setEnabled:!editing];
    
    for (DTField *field in editableFields) {
        if (field.isEditable) {
            [field setEditing:editing animated:YES];
        }
    }
}

- (IBAction)beginEdit:(id)sender
{
    [self setEditing:YES animated:YES];
}

- (IBAction)endEdit:(id)sender
{
    if (sender == self.cancelButton) {
        for (DTField *field in editableFields) {
            if (field.state == DTEditableViewStateEditing) {
                [field revert];
            }
        }
        [self setEditing:NO animated:YES];
        [self initializeFromConfiguration];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }];
    } else {
        if (![DTConnection canSendMessages]) {
            [[UIAlertView alertViewForNotConnectedToInternet] show];
            return;
        }
        
        DTActivityIndicatorView *activity = [[DTActivityIndicatorView alloc] init];
        [activity show];
        
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:self.equipmentId forKey:@"id"];
            if (self.planView.planId) {
                [params setObject:[self.planView.planId description] forKey:@"planSelect"];
            } else {
                [params setObject:[NSNull null] forKey:@"planSelect"];
            }
            if (self.planView.planStep) {
                [params setObject:[self.planView.planStep description] forKey:@"planStepSelect"];
            } else {
                [params setObject:[NSNull null] forKey:@"planStepSelect"];
            }
            
            if (self.speedDepthView.speedField.value) {
                [params setObject:self.speedDepthView.speedField.value forKey:@"applicationRate"];
            } else {
                [params setObject:[NSNull null] forKey:@"applicationRate"];
            }
            
            [params setObject:self.directionView.direction forKey:@"directionOption"];
            
            [params setObject:self.waterView.on ? @"1" : @"0" forKey:self.waterView.name];
            
            [params setObject:self.serviceStopView.autoRepeat ? @"1" : @"0" forKey:self.serviceStopView.autoRepeatName];
            
            if (self.serviceStopView.value) {
                [params setObject:[self.serviceStopView.value description] forKey:@"serviceStop"];
            } else {
                [params setObject:[NSNull null] forKey:@"serviceStop"];
            }
            
            [params setObject:self.chemigationView.on ? @"1" : @"0" forKey:self.chemigationView.name];
            [params setObject:self.accessoryOneView.on ? @"1" : @"0" forKey:self.accessoryOneView.name];
            [params setObject:self.accessoryTwoView.on ? @"1" : @"0" forKey:self.accessoryTwoView.name];
            
            DTResponse *response = [DTConnection postTo:FN3APIEquipmentOptions parameters:params];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                if (response.isSuccess) {
                    [self.pollButton pollEquipmentId:self.equipmentId functionId:[response.data objectForKey:@"function_id"]];
                    [self setEditing:NO animated:YES];
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                } else {
                    for (DTField *field in editableFields) {
                        if (field.state == DTEditableViewStateEditing) {
                            [field revert];
                        }
                    }
                    [self initializeFromConfiguration];
                    
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
            }];
        };
        [[NSOperationQueue networkQueue] addNetworkOperation:op];
    }
}

#pragma mark - Initialization methods

- (void)initializeFromEquipment
{
    if (self.isEditing) {
        return;
    }
    
    lateral = nil;
    lateral = (DTLateral *)[DTEquipment equipmentWithId:self.equipmentId 
                                          inContext:store.managedObjectContext];
    
    [lateralView configureFromEquipment:lateral];
    lateralView.detailLevel = DTEquipmentDetailLevelDetail;
    lateralView.borderWidth = 7;
    
    UILabel *title = (UILabel *)self.navigationItem.titleView;
    title.text = lateral.title;
    CGSize size = [title sizeThatFits:CGSizeMake(0, 0)];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, size.width, size.height);
    
    [(DTConnectionView *)[self.headerView viewWithTag:1] setCommStatus:lateral.commStatus];
    
    if (!self.pollButton.isInPollError) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = formatter.timeStyle = NSDateFormatterShortStyle;
        [(UILabel *)[self.headerView viewWithTag:2] setText:[formatter stringFromDate:lateral.lastUpdated]];
        [(UILabel *)[self.headerView viewWithTag:2] setTextColor:[UIColor whiteColor]];
    }
    
    [self.planView setDriver:lateral.driver planId:lateral.planId step:lateral.planStepValue];
    
    [(UILabel *)[self.statusSummaryView viewWithTag:1] setText:lateral.subtitle];
    if (lateral.position) {
        [(UILabel *)[self.currentPositionView viewWithTag:1] setText:[NSString stringWithFormat:@"%@ %@", lateral.position, lateral.positionUom]];
    } else {
        [(UILabel *)[self.currentPositionView viewWithTag:1] setText:nil];
    }
    
    [(UILabel *)[self.durationView viewWithTag:1] setText:lateral.durationDescription];
    
    [self.directionView setDirection:lateral.directionOption];
    
    NSString *depthTitle = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Depth to apply", nil), lateral.depthUom];
    self.speedDepthView.speedTitle = NSLocalizedString(@"Speed %", nil);
    self.speedDepthView.depthTitle = depthTitle;
    [self.speedDepthView.depthField setValue:0 units:[NSString stringWithFormat:@" %@", lateral.depthUom]];
    
    self.speedDepthView.depthConversionFactor = lateral.depthConversionFactor;
    [self.speedDepthView.speedField setValue:lateral.rate units:@"%"];
    [self.speedDepthView setSpeed:lateral.rate];
    self.speedDepthView.isWaterOn = [lateral.water boolValue];
    
    if (lateral.isPumpTypeEngine) {
        self.waterView.onImage = [UIImage imageNamed:@"lateral_pump_selected.png"];
        self.waterView.offImage = [UIImage imageNamed:@"lateral_pump.png"];
        self.waterView.toggleImage = [UIImage imageNamed:@"lateral_pump_black.png"];
    }
    
    self.waterView.on = [lateral.water boolValue];
        
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    numberFormat.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormat.maximumFractionDigits = 2;
    
    if (lateral.pressure.value) {
        DTEquipmentDataField *pressure = lateral.pressure;
        [(UITextField *)[self.psiView viewWithTag:1] setText:[NSString stringWithFormat:@"%@ %@", [numberFormat stringFromNumber:pressure.numericValue], pressure.uom]];
    } else {
        [(UITextField *)[self.psiView viewWithTag:1] setText:nil];
    }
    
    if (lateral.flow.value) {
        DTEquipmentDataField *flow = lateral.flow;
        [(UITextField *)[self.gpmView viewWithTag:1] setText:[NSString stringWithFormat:@"%@ %@", [numberFormat stringFromNumber:flow.numericValue], flow.uom]];
    } else {
        [(UITextField *)[self.gpmView viewWithTag:1] setText:nil];
    }
    
    [self.serviceStopView setValue:lateral.servicePosition units:lateral.servicePositionUom];
    [self.serviceStopView setMaxValue:lateral.widthMeters.floatValue];
    self.serviceStopView.autoRepeat = [lateral.repeatServiceStop boolValue];
    
    if (lateral.chemigation) {
        self.chemigationView.on = [lateral.chemigation.value boolValue];
    } else {
        self.chemigationView.on = NO;
    }
    
    if (lateral.accessoryOne) {
        self.accessoryOneView.on = [lateral.accessoryOne.value boolValue];
    } else {
        self.accessoryOneView.on = NO;
    }
    
    if (lateral.accessoryTwo) {
        self.accessoryTwoView.on = [lateral.accessoryTwo.value boolValue];
    } else {
        self.accessoryTwoView.on = NO;
    }
    
    if (lateral.voltage.value) {
        DTEquipmentDataField *voltage = lateral.voltage;
        [(UITextField *)[self.voltageValueView viewWithTag:1] setText:voltage.value];
    } else {
        [(UITextField *)[self.voltageValueView viewWithTag:1] setText:@"- - -"];
    }
    
    if (lateral.voltage.uom) {
        DTEquipmentDataField *voltage = lateral.voltage;
        [(UITextField *)[self.voltageTypeView viewWithTag:1] setText:voltage.uom];
    } else {
        [(UITextField *)[self.voltageTypeView viewWithTag:1] setText:nil];
    }
    
    if (lateral.temperature.value) {
        DTEquipmentDataField *temperature = lateral.temperature;
        [(UITextField *)[self.tempValueView viewWithTag:1] setText:temperature.value];
    } else {
        [(UITextField *)[self.tempValueView viewWithTag:1] setText:@"- - -"];
    }
    
    if (lateral.temperature.uom) {
        DTEquipmentDataField *temperature = lateral.temperature;
        [(UITextField *)[self.tempTypeView viewWithTag:1] setText:temperature.uom];
    } else {
        [(UITextField *)[self.tempTypeView viewWithTag:1] setText:nil];
    }
    
    [self initializeFromConfiguration];
}

- (void)initializeFromConfiguration
{
    // set the permissions
    self.directionView.availableDirectionsNames = nil;
    self.directionView.availableDirectionsValues = nil;
    NSSet *availableFieldNames;
    NSSet *editableFieldNames;
    BOOL editable = NO;
    if (lateral.driver && lateral.planId) {
        DTConfiguration *config = [DTConfiguration configurationNamed:lateral.driver inContext:store.managedObjectContext];
        if (config) {
            DTPlan *plan = [DTPlan configuration:config planById:lateral.planId];
            if (plan) {
                editable = YES;
                editableFieldNames = plan.editableFieldNames;
            }
            
            self.directionView.availableDirectionsNames = config.availableDirectionNames;
            self.directionView.availableDirectionsValues = config.availableDirectionValues;
            availableFieldNames = config.availableFieldNames;
            requiresWaterFieldNames = config.requiresWaterFieldNames;
            
            if (!config.displayTemperature) {
                [(UITextField *)[self.tempValueView viewWithTag:1] setText:@"- - -"];
            }
            
            if (!config.displayVoltage) {
                [(UITextField *)[self.voltageValueView viewWithTag:1] setText:@"- - -"];
            }
        }
    }
    
    if (editable) {
        if (!self.navigationItem.rightBarButtonItem) {
            [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
        }
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    for (DTField *field in editableFields) {
        [field setEditableFields:editableFieldNames availableFields:availableFieldNames];
        
        if (field.isAvailable) {
            field.backgroundView.background = [field.backgroundView.background shaderWithAlpha:1];
            field.backgroundView.border = [field.backgroundView.border borderWithAlpha:1];
        } else {
            field.backgroundView.background = [field.backgroundView.background shaderWithAlpha:0.7];
            field.backgroundView.border = [field.backgroundView.border borderWithAlpha:0.7];
        }
        [field.backgroundView setNeedsDisplay];
    }
}

#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self initializeFromEquipment];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionNumber
{
    id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
    NSInteger count = [section numberOfObjects];
    
    if (isFetchingData || hasMoreHistory) {
        count++;
    } else if (!hasMoreHistory && count == 0) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
    if (indexPath.row < [section objects].count) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *durationLabel = (UILabel *)[cell viewWithTag:3];
        
        DTEquipmentHistory *history = [[section objects] objectAtIndex:indexPath.row];
        
        dateLabel.text = [dateFormatter stringFromDate:history.date];
        statusLabel.text = history.statusSummary;
        durationLabel.text = history.durationDescription;
        
        return cell;
    } else {
        UITableViewCell *cell;
        
        if ([section numberOfObjects] == 0 && !isFetchingData && !hasMoreHistory) {
            cell  = [tableView dequeueReusableCellWithIdentifier:@"HistoryNoDataCell"];
        } else {
            cell  = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [UIView tableHeaderViewWithTitle:nil];
    header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, tableView.frame.size.width, 44);
    
    UILabel *col1 = (UILabel *)[header viewWithTag:1];
    col1.textAlignment = UITextAlignmentCenter;
    col1.numberOfLines = 2;
    col1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    col1.adjustsFontSizeToFitWidth = YES;
    CGSize size;
    col1.text = NSLocalizedString(@"History", nil);
    col1.frame = CGRectMake(5, 4, (col1.superview.frame.size.width - 20) / 3.0, 32);
    size = col1.frame.size;
    
    UILabel *col2 = [[UILabel alloc] initWithFrame:CGRectMake(col1.frame.origin.x + col1.frame.size.width + 5, col1.frame.origin.y, size.width, size.height)];
    col2.backgroundColor = col1.backgroundColor;
    col2.font = col1.font;
    col2.textAlignment = col1.textAlignment;
    col2.textColor = col1.textColor;
    col2.text = NSLocalizedString(@"Status", nil);
    col2.numberOfLines = col1.numberOfLines;
    col2.adjustsFontSizeToFitWidth = col1.adjustsFontSizeToFitWidth;
    col2.autoresizingMask = col1.autoresizingMask;
    [col1.superview addSubview:col2];
    
    UILabel *col3 = [[UILabel alloc] initWithFrame:CGRectMake(col2.frame.origin.x + col2.frame.size.width + 5, col2.frame.origin.y, size.width, size.height)];
    col3.backgroundColor = col1.backgroundColor;
    col3.font = col1.font;
    col3.textAlignment = col1.textAlignment;
    col3.textColor = col1.textColor;
    col3.numberOfLines = col1.numberOfLines;
    col3.autoresizingMask = col1.autoresizingMask;
    col3.text = NSLocalizedString(@"Duration", nil);
    [col1.superview addSubview:col3];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 44 : -1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
    if (indexPath.row < [section objects].count) {
        return 54;
    } else {
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> section = resultsController.sections.lastObject;
    if (indexPath.row >= [section objects].count && hasMoreHistory) {
        [self fetchNextPage];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    DTEquipmentHistory *equipmentHistory;
    
    NSIndexPath *indexPath = [(UITableView *)self.view indexPathForCell:cell];
    equipmentHistory = [resultsController objectAtIndexPath:indexPath];
    
    [(DTHistoryDetailViewController *)segue.destinationViewController setEventId:equipmentHistory.eventId];
    
}

@end
