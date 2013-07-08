//
//  DTEquipmentAlertsViewController.h
//  FN3
//
//  Created by David Jablonski on 4/9/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTEquipmentAlertsViewController : UITableViewController {
    NSNumber *equipmentId;
    NSMutableSet *unviewedAlertIds;
    NSFetchedResultsController *resultsController;
    
    UIFont *labelFont;
    UILineBreakMode labelLineBreakMode;
    CGRect labelFrame;
}
@property (nonatomic, retain) NSNumber *equipmentId;

@end
