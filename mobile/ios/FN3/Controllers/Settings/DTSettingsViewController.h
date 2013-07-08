//
//  DTUserViewController.h
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTSettings, DTPersistentStore;

@interface DTSettingsViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    DTPersistentStore *store;
    DTSettings *settings;
    NSFetchedResultsController *notifications;
    
    UITextField *emailEditField;
    UISwitch *rememberMeField;
    NSMutableDictionary *notificationControls;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)beginEditing:(id)sender;
- (IBAction)saveEditing:(id)sender;
- (IBAction)cancelEditing:(id)sender;
- (IBAction)logout:(id)sender;

@end
