//
//  DTGeneralIOViewController.h
//  FN3
//
//  Created by David Jablonski on 4/28/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDashboardViewController.h"

@class DTPersistentStore, DTGeneralIO, DTView, DTEditableView, DTPollButton;

@interface DTGeneralIODashboardViewController : UITableViewController <DTDashboardViewController, UIAlertViewDelegate> {
    NSNumber *equipmentId;
    
    DTPersistentStore *store;
    DTGeneralIO *generalIO;
    NSArray *fields;
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
    BOOL isUpdatingStatus;
}

@property (weak, nonatomic) IBOutlet DTView *headerView;
@property (weak, nonatomic) IBOutlet DTPollButton *pollButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeStatusButton;

- (IBAction)poll:(id)sender;
- (IBAction)changeStatus:(id)sender;

@end
