//
//  DTEquipmentGroupViewController.h
//  FN3
//
//  Created by David Jablonski on 3/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTPersistentStore;

@interface DTEquipmentGroupViewController : UITableViewController {
    DTPersistentStore *store;
    NSFetchedResultsController *resultsController;
    BOOL isExpired;
}

@end
