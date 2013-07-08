//
//  DTEquipmentController.h
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DTDashboardViewController.h"
#import "DTPlanSelectField.h"
#import "DTSpeedDepthField.h"
#import "DTServiceStopField.h"
#import "DTToggleField.h"

@class DTPersistentStore, DTPivot, DTPollButton;
@class DTView, DTPivotView, DTEditableView, DTNumberField, DTDirectionField, DTToggleField, DTServiceStopField, DTSpeedDepthField;

@interface DTPivotDashboardViewController : UITableViewController <DTDashboardViewController, DTPlanSelectFieldDelegate, DTSpeedDepthFieldDelegate, DTServiceStopFieldDelegate, DTToggleFieldDelegate> {
    IBOutlet DTView *leftView;
    IBOutlet DTPivotView *pivotView;
    NSFetchedResultsController *resultsController;
    
    NSNumber *equipmentId;
    DTPersistentStore *store;
    DTPivot *pivot;
    
    UIView *equipmentView;
    
    NSArray *editableFields;
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
    BOOL hasMoreHistory;
    BOOL isFetchingData;
    BOOL isDoingInitialFetch;
    BOOL hasLoadedViewBefore;
    NSInteger lastContentOffset;
    
    NSInteger historyTableSize;
    NSInteger totalHistoryRecordsRemaining;
    NSInteger historyRecordsRequestSize;
    
    NSSet *requiresWaterFieldNames;
}

@property (nonatomic, retain) NSNumber *equipmentId;

@property (strong, nonatomic) IBOutlet DTView *headerView;

@property (strong, nonatomic) IBOutlet DTPlanSelectField *planView;
@property (strong, nonatomic) IBOutlet DTPollButton *pollButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (strong, nonatomic) IBOutlet DTView *statusSummaryView;
@property (strong, nonatomic) IBOutlet DTView *currentPositionView;
@property (strong, nonatomic) IBOutlet DTView *durationView;

@property (strong, nonatomic) IBOutlet DTDirectionField *directionView;
@property (strong, nonatomic) IBOutlet DTSpeedDepthField *speedDepthView;

@property (strong, nonatomic) IBOutlet DTToggleField *waterView;
@property (strong, nonatomic) IBOutlet DTView *psiView;
@property (strong, nonatomic) IBOutlet DTView *gpmView;

@property (weak, nonatomic) IBOutlet DTView *tempValueView;
@property (weak, nonatomic) IBOutlet DTView *tempTypeView;
@property (weak, nonatomic) IBOutlet UILabel *voltageValueView;
@property (weak, nonatomic) IBOutlet DTView *voltageTypeView;

@property (strong, nonatomic) IBOutlet DTView *controlsHeader;
@property (strong, nonatomic) IBOutlet DTServiceStopField *serviceStopView;
@property (strong, nonatomic) IBOutlet DTView *bottomRightView;

@property (strong, nonatomic) IBOutlet DTToggleField *chemigationView;
@property (strong, nonatomic) IBOutlet DTToggleField *accessoryOneView;
@property (strong, nonatomic) IBOutlet DTToggleField *accessoryTwoView;
@property (strong, nonatomic) IBOutlet DTView *voltageTempTitleView;
@property (strong, nonatomic) IBOutlet DTView *voltageTempView;
@property (strong, nonatomic) IBOutlet DTView *accessoryTitleView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessoriesLabel;

- (IBAction)beginEdit:(id)sender;
- (IBAction)endEdit:(id)sender;

- (IBAction)poll:(id)sender;

@end
