//
//  DTEquipmentListViewController.h
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DTEquipmentGroup, DTSearchTableDisplayController, DTPersistentStore;

@interface DTEquipmentListViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    DTEquipmentGroup *group;
    
    DTPersistentStore *store;
    NSFetchedResultsController *resultsController;
    
    IBOutlet DTSearchTableDisplayController *searchBarDisplayController;
    NSFetchedResultsController *searchResultsController;
    
    NSTimer *refreshTimer;
    BOOL isRunningRefresh;
}
@property (nonatomic, retain) DTEquipmentGroup *group;

@end
