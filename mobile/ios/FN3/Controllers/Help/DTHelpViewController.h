//
//  HelpViewController.h
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTSearchTableDisplayController, DTHelpSearchDataSource, DTPersistentStore;
@class DTConnectionView, DTPivotView, DTLateralView, DTPumpView, DTPumpStationView;

@interface DTHelpViewController : UITableViewController {
    IBOutlet DTSearchTableDisplayController *searchBarDisplayController;
    DTHelpSearchDataSource *searchDataSource;
    NSFetchedResultsController *iconController;
    
    DTPersistentStore *store;
    
    NSMutableArray *sizedIndexPaths;
}

- (IBAction)viewFullSite:(id)sender;

@end
