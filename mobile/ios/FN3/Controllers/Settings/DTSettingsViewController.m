//
//  DTUserViewController.m
//  FN3
//
//  Created by David Jablonski on 2/22/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSettingsViewController.h"
#import "DTChangePasswordViewController.h"
#import "DTAppDelegate.h"
#import "DTCredentials.h"

#import "UIView+DTCustomViews.h"
#import "NSString+DTString.h"

#import "DTSettings.h"
#import "DTNotificationSetting.h"
#import "DTPersistentStore.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTSettingsParser.h"
#import "DTLoadDataOperation.h"
#import "DTPushTokenOperation.h"

#import "DTActivityIndicatorView.h"
#import "DTEquipmentGroup.h"
#import "DTConnection.h"
#import "DTResponse.h"

#import "UIAlertView+DTAlertView.h"
#import "UIColor+DTColor.h"

#import "DTAnalytics.h"

@implementation DTSettingsViewController

@synthesize editButton;
@synthesize logoutButton;
@synthesize cancelButton;
@synthesize saveButton;
@synthesize versionLabel;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
    [(UITableView *)self.view setBackgroundView:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:nil 
                                                                  action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    self.saveButton.tintColor = [UIColor barButtonSaveItemTintColor];
    [self.saveButton setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]
                                   forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(settingsUpdated:) 
                                                 name:DTSettingsUpdate 
                                               object:nil];
    
    emailEditField = [[UITextField alloc] init];
    emailEditField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailEditField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailEditField.returnKeyType = UIReturnKeyDone;
    emailEditField.keyboardType = UIKeyboardTypeEmailAddress;
    emailEditField.delegate = self;
    emailEditField.clearButtonMode = UITextFieldViewModeAlways;
    emailEditField.borderStyle = UITextBorderStyleRoundedRect;
    emailEditField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    emailEditField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailEditField.font = [UIFont systemFontOfSize:14];
    
    rememberMeField = [[UISwitch alloc] init];
    
    notificationControls = [[NSMutableDictionary alloc] init];
    
    NSString *environment;
    environment = [NSString stringWithString:[DTConnection getHost]];

    if ([environment hasPrefix:@"https"]) {
        environment = [environment substringFromIndex:8];
    } else if ([environment hasPrefix:@"http"]) {
        environment = [environment substringFromIndex:7];
    }
    
    NSRange endIdx = [environment rangeOfString:@"."];
    
    if (endIdx.location != NSNotFound){
        environment = [environment substringToIndex:endIdx.location];
    }
    
    if ([environment isEqualToString:@"app"]) {
        //environment = [NSString stringWithString:@""];
        environment = @""
        ;    } else {
        environment = [NSString stringWithFormat:@" - %@", environment];
    }
    
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ v%@%@", name, version, environment];
    
    environment = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    settings = nil;
    notifications = nil;
    
    emailEditField = nil;
    rememberMeField = nil;
    notificationControls = nil;
    
    [self setEditButton:nil];
    [self setLogoutButton:nil];
    [self setCancelButton:nil];
    [self setSaveButton:nil];
    
    [self setVersionLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

- (void)settingsUpdated:(NSNotification *)notification
{
    if (![self isEditing]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            NSLog(@"updating settings");
            [(UITableView *)self.view reloadData];
        }];
    }
}

- (void)loadData
{
    store = [[DTPersistentStore alloc] init];
    
    settings = [DTSettings defaultSettingsInContext:store.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[DTNotificationSetting class] description]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"settings = %@", settings];
    
    notifications = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                        managedObjectContext:store.managedObjectContext
                                                          sectionNameKeyPath:nil 
                                                                   cacheName:nil];
    NSError *error;
    [notifications performFetch:&error]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self loadData];
    
    NSInteger count = 1;
    if (notifications.sections.count > 0) {
        id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
        if ([section objects].count > 0) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else {
        id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
        return [section objects].count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? NSLocalizedString(@"Account", nil) : NSLocalizedString(@"Notifications", nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView tableHeaderViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RememberMeCell"];
            [self configureCell:cell forIndexPath:indexPath];
            return cell;
        } else if (indexPath.row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangePasswordCell"];
            [self configureCell:cell forIndexPath:indexPath];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
            [self configureCell:cell forIndexPath:indexPath];
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
        [self configureCell:cell forIndexPath:indexPath];
        
        return cell;
    }
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            cell.editingAccessoryView = rememberMeField;
            rememberMeField.on = [DTCredentials instance].isStoredInKeychain;
            
            UILabel *accessory;
            if (cell.accessoryView) {
                accessory = (UILabel *)cell.accessoryView;
            } else {
                accessory = [[UILabel alloc] init];
                accessory.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                accessory.textColor = [UIColor blackColor];
                accessory.backgroundColor = [UIColor clearColor];
                cell.accessoryView = accessory;
            }
            
            accessory.text = NSLocalizedString(rememberMeField.on ? @"On" : @"Off", nil);
            CGSize labelSize = [accessory sizeThatFits:CGSizeMake(self.view.frame.size.width, 40)];
            accessory.frame = CGRectMake(0, 0, labelSize.width + 5, labelSize.height);
        } else if (indexPath.row == 2) {
        } else {
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            if (indexPath.row == 0) {
                label.text = NSLocalizedString(@"Username", nil);
            } else if (indexPath.row == 1) {
                label.text = NSLocalizedString(@"Email", nil);
            }
            
            UILabel *value = (UILabel *)[cell viewWithTag:2];
            value.text = [self valueForRow:indexPath.row inSection:indexPath.section];
            
            if (indexPath.row != 0 && !cell.editingAccessoryView) {
                UITextField *textField = [self editingAccessoryViewForRow:indexPath.row inSection:indexPath.section];
                CGSize size = [textField sizeThatFits:CGSizeMake(0, 0)];
                textField.frame = CGRectMake(value.frame.origin.x, 
                                             (cell.frame.size.height - size.height) / 2.0, 
                                             value.frame.size.width, 
                                             size.height);
                [value.superview addSubview:textField];
                
                if (self.isEditing) {
                    value.alpha = 0;
                    textField.alpha = 1;
                } else {
                    value.alpha = 1;
                    textField.alpha = 0;
                    textField.text = value.text;
                }
            }
        }
    } else {
        id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
        DTNotificationSetting *setting = [[section objects] objectAtIndex:indexPath.row];
        
        [(UILabel *)[cell viewWithTag:1] setText:NSLocalizedString(setting.label, nil)];
        
        BOOL on = [[self valueForRow:indexPath.row inSection:indexPath.section] boolValue];
        UILabel *accessory;
        if (cell.accessoryView) {
            accessory = (UILabel *)cell.accessoryView;
        } else {
            accessory = [[UILabel alloc] init];
            accessory.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            accessory.textColor = [UIColor blackColor];
            accessory.backgroundColor = [UIColor clearColor];
            cell.accessoryView = accessory;
        }
        accessory.text = NSLocalizedString(on ? @"On" : @"Off", nil);
        CGSize labelSize = [accessory sizeThatFits:CGSizeMake(0, cell.frame.size.height)];
        accessory.frame = CGRectMake(0, 0, labelSize.width + 5, labelSize.height);
        
        if (!cell.editingAccessoryView) {
            cell.editingAccessoryView = [self editingAccessoryViewForRow:indexPath.row inSection:indexPath.section];
            if (!self.isEditing) {
                [(UISwitch *) cell.editingAccessoryView setOn:on];
            }
        }
    }
}

- (id)editingAccessoryViewForRow:(NSInteger)row inSection:(NSInteger)section
{
    if (section == 0) {
        switch (row) {
            case 1: return emailEditField;
            case 2: return rememberMeField;
        }
    } else if (section == 1) {
        id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
        DTNotificationSetting *setting = [[section objects] objectAtIndex:row];
        
        if (![notificationControls objectForKey:setting.name]) {
            [notificationControls setObject:[[UISwitch alloc] init] forKey:setting.name];
        }
        return [notificationControls objectForKey:setting.name];
    }
    return nil;
}

- (id)valueForRow:(NSInteger)row inSection:(NSInteger)section
{
    if (section == 0) {
        switch (row) {
            case 0: return settings.userName;
            case 1: return settings.email;
        }
    } else if (section == 1) {
        id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
        DTNotificationSetting *setting = [[section objects] objectAtIndex:row];
        return setting.on;
    }

    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)beginEditing:(id)sender
{
    [self setEditing:YES animated:YES];
}

- (IBAction)saveEditing:(id)sender
{
    if (![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        [self cancelEditing:self.cancelButton];
        return;
    }
    
    DTActivityIndicatorView *activity = [[DTActivityIndicatorView alloc] init];
    [activity show];
    
    UITableView *tableView = (UITableView *)self.view;
    for (int i = 1; i <= 2; i++) {
        [[self editingAccessoryViewForRow:i inSection:0] resignFirstResponder];
    }
    
    NSString *userName = settings.userName;
    
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
        BOOL valuesChanged = ![settings.email isEqualToString:emailEditField.text];
        for (NSString *name in notificationControls) {
            DTNotificationSetting *ns = [settings settingForNotification:name];
            UISwitch *sw = [notificationControls objectForKey:name];
            valuesChanged = valuesChanged || [ns.on boolValue] != sw.on;
        }
        
        if (valuesChanged) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            if (emailEditField.text) {
                [params setObject:emailEditField.text forKey:@"email"];
            } else {
                [params setObject:@"" forKey:@"email"];
            }
            for (NSString *name in notificationControls) {
                UISwitch *sw = [notificationControls objectForKey:name];
                NSString *key = [[NSString stringWithFormat:@"alert_%@", name] camelize];
                [params setObject:[[NSNumber numberWithBool:sw.on] description] forKey:key];
            }
            
            DTResponse *response = [DTConnection postTo:FN3APISettings 
                                             parameters:params];
            
            if (response && response.isSuccess) {
                DTPersistentStore *ps = [[DTPersistentStore alloc] init];
                
                DTSettings *update = [DTSettings settingsWithUserName:userName inContext:ps.managedObjectContext];
                update.email = emailEditField.text;
                for (NSString *name in notificationControls) {
                    UISwitch *sw = [notificationControls objectForKey:name];
                    [update settingForNotification:name].on = [NSNumber numberWithBool:sw.on];
                }
                [ps save];
                
                if ([DTCredentials instance].isStoredInKeychain != rememberMeField.on) {
                    if (rememberMeField.on) {
                        [[DTCredentials instance] storeInKeychain];
                    } else {
                        [[DTCredentials instance] removeFromKeychain];
                    }
                }
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    [self refreshTableView:tableView];
                    [self setEditing:NO animated:YES];
                    
                    // pull from the server to make sure we're in-sync
                    [[NSOperationQueue networkQueue] addNetworkOperationWithBlock:^(void){
                        DTResponse *settingsResponse = [DTConnection getTo:FN3APISettings parameters:nil];
                        if (settingsResponse.isSuccess) {
                            DTSettingsParser *parser = [[DTSettingsParser alloc] initWithResponse:settingsResponse.data username:userName];
                            [[NSOperationQueue parserQueue] addOperation:parser];
                        }
                    }];
                }];
            } else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    [self cancelEditing:self.cancelButton];
                    if (response.isAuthenticationError) {
                        [[UIAlertView alertViewForNotAuthenticated] show];
                        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                    } else {
                        [[UIAlertView alertViewForResponse:response 
                                            defaultMessage:NSLocalizedString(@"There was an error saving settings.", nil)] show];
                    }
                }];
            }
        } else {
            if ([DTCredentials instance].isStoredInKeychain != rememberMeField.on) {
                if (rememberMeField.on) {
                    [[DTCredentials instance] storeInKeychain];
                } else {
                    [[DTCredentials instance] removeFromKeychain];
                }
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [self refreshTableView:tableView];
                [self setEditing:NO animated:YES];
            }];
        }
    }];
    op.completionBlock = ^(void){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            [activity dismiss];
        }];
    };
    
    [[NSOperationQueue networkQueue] addNetworkOperation:op];
}

- (IBAction)cancelEditing:(id)sender
{
    [self setEditing:NO animated:YES];
}

// refresh the table without reloading, which will cancel the animations
- (void)refreshTableView:(UITableView *)tableView
{
    [self loadData];
    for (int section = 0; section < [self numberOfSectionsInTableView:tableView]; section++) {
        for (int row = 0; row < [self tableView:tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:indexPath];
            if (cell) {
                [self configureCell:cell forIndexPath:indexPath];
            }
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing == self.isEditing) {
        return;
    } else if (editing && ![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    [self.navigationItem setRightBarButtonItem:editing ? saveButton : editButton 
                                      animated:animated];
    [self.navigationItem setLeftBarButtonItem:editing ? cancelButton : logoutButton 
                                     animated:animated];
    
    // if editing, set the values on the editing accessories
    if (editing) {
        UITextField *tf = [self editingAccessoryViewForRow:1 inSection:0];
        [tf setText:[self valueForRow:1 inSection:0]];
        
        if (notifications.sections.count > 0) {
            id<NSFetchedResultsSectionInfo> section = [notifications.sections objectAtIndex:0];
            
            for (int i = 0; i < [section objects].count; i++) {
                UISwitch *sw = [self editingAccessoryViewForRow:i inSection:1];
                [sw setOn:[[self valueForRow:i inSection:1] boolValue]];
            }
        }
    } else {
        [[self editingAccessoryViewForRow:1 inSection:0] resignFirstResponder];
        [[self editingAccessoryViewForRow:2 inSection:0] resignFirstResponder];
    }
    
    [super setEditing:editing animated:animated];
    
    // swap in/out the text field editing accessories
    for (int i = 1; i < 2; i++) {
        UITextField *textField = [self editingAccessoryViewForRow:i inSection:0];
        UILabel *label = (UILabel *)[textField.superview viewWithTag:2];
        
        CGFloat animationDuration = animated ? 0.3 : 0;
        if (editing) {
            CGRect textFrame = textField.frame;
            textField.frame = CGRectMake(textFrame.origin.x + 20,
                                         textFrame.origin.y, 
                                         textFrame.size.width, 
                                         textFrame.size.height);

            [UIView animateWithDuration:animationDuration animations:^(void){
                label.alpha = 0;
                textField.frame = textFrame;
                textField.alpha = 1;
            }];
        } else {
            [textField resignFirstResponder];
            CGRect textFrame = textField.frame;
            [UIView animateWithDuration:animationDuration
                             animations:^(void){
                                 label.alpha = 1;
                                 textField.frame = CGRectMake(textFrame.origin.x + 20, 
                                                              textFrame.origin.y, 
                                                              textFrame.size.width, 
                                                              textFrame.size.height);
                                 textField.alpha = 0;
                             }  
                             completion:^(BOOL finished){
                                 textField.frame = textFrame;
                             }];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)logout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log Out?", nil)
                                                    message:NSLocalizedString(@"Are you sure you want to log out?", nil)
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Log Out", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        DTActivityIndicatorView *activityIndicator = [[DTActivityIndicatorView alloc] init];
        [activityIndicator show];
        
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            for (id key in [defaults dictionaryRepresentation]) {
                [defaults removeObjectForKey:key];
            }
            [defaults synchronize];
            
            [[NSOperationQueue networkQueue] cancelAllOperations];
            [[NSOperationQueue networkQueue] waitUntilAllOperationsAreFinished];
            [[NSOperationQueue parserQueue] cancelAllOperations];
            [[NSOperationQueue parserQueue] waitUntilAllOperationsAreFinished];
            
            // remove the push token
            [[NSOperationQueue networkQueue] addOperation:[[DTPushTokenOperation alloc] initWithToken:nil]];
            [[NSOperationQueue networkQueue] waitUntilAllOperationsAreFinished]; 
            
            DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate clearUserData];
            
            DTCredentials *credentials = [DTCredentials instance];
            [credentials removeFromKeychain];
            credentials.username = credentials.password = nil;
        }];
        op.completionBlock = ^(void){
            settings = nil;
            notifications = nil;
            store = nil;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [(UITableView *)self.view reloadData];
                [activityIndicator dismiss];
                [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
            }];
        };
        [[NSOperationQueue backgroundQueue] addOperation:op];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"SegueToChangePasswordScene" isEqualToString:segue.identifier]) {
        [(DTChangePasswordViewController *)segue.destinationViewController setUsername:settings.userName];
    }
}

@end
