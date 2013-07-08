//
//  DTHistoryDetailViewController.h
//  FieldNET
//
//  Created by Loren Davelaar on 8/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDashboardViewController.h"

@class DTPersistentStore, DTEquipmentHistory, DTView;

@interface DTHistoryDetailViewController : UITableViewController {
    
    DTPersistentStore *store;
    DTEquipmentHistory *equipmentHistory;
    NSArray *fields;
}

@property (weak, nonatomic) IBOutlet DTView *headerView;
@property (nonatomic, retain) NSNumber *eventId;

@end
