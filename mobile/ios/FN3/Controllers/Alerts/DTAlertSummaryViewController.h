//
//  DTSecondViewController.h
//  FN3
//
//  Created by David Jablonski on 2/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTEquipmentGroup, DTSearchTableDisplayController, DTPersistentStore;

@interface DTAlertSummaryViewController : UITableViewController {
    DTEquipmentGroup *group;
    
    DTPersistentStore *store;
    NSFetchedResultsController *resultsController;
    NSArray *sortedSections;
    
    IBOutlet DTSearchTableDisplayController *searchController;
    NSFetchedResultsController *searchResultsController;
    NSArray *sortedSearchSections;
    
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
}
@property (nonatomic, retain) DTEquipmentGroup *group;

@end
