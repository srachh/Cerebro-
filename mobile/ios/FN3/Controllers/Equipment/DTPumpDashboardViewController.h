//
//  DTPumpDashboardViewController.h
//  FN3
//
//  Created by David Jablonski on 4/11/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDashboardViewController.h"

@class DTView, DTGreenButton, DTEditableView, DTPollButton;
@class DTPersistentStore, DTPumpStation;


@interface DTPumpDashboardViewController : UITableViewController <DTDashboardViewController, UIAlertViewDelegate> {
    NSNumber *equipmentId;
    
    DTPersistentStore *store;
    DTPumpStation *pumpStation;
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
    BOOL isUpdatingStatus;
}


@property (strong, nonatomic) IBOutlet DTView *pressureGaugeContainer;
@property (strong, nonatomic) IBOutlet DTView *pressureContainer;

@property (strong, nonatomic) IBOutlet DTView *flowGaugeContainer;
@property (strong, nonatomic) IBOutlet DTView *flowContainer;

@property (strong, nonatomic) IBOutlet DTView *powerGaugeContainer;
@property (strong, nonatomic) IBOutlet DTView *powerContainer;

@property (strong, nonatomic) IBOutlet DTView *headerView;
@property (strong, nonatomic) IBOutlet DTPollButton *pollButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeStatusButton;

- (IBAction)poll:(id)sender;
- (IBAction)changeStatus:(id)sender;

@end
