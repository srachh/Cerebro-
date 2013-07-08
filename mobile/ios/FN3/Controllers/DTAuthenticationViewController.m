//
//  DTAuthenticationViewController.m
//  FN3
//
//  Created by David Jablonski on 3/5/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAuthenticationViewController.h"
#import "DTAppDelegate.h"
#import "NSString+DTString.h"
#import "NSData+DTData.h"

#import "DTTranslation.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTTTranslationParser.h"
#import "DTLoadDataOperation.h"
#import "DTPushTokenOperation.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTPersistentStore.h"
#import "DTSettings.h"
#import "DTActivityIndicatorView.h"
#import "FN3ApiStatus.h"
#import "DTCredentials.h"
#import "DTEquipmentParser.h"

#import "UIAlertView+DTAlertView.h"

#import "DTAnalytics.h"


@implementation DTAuthenticationViewController

@synthesize usernameCell, usernameField;
@synthesize passwordCell, passwordField;
@synthesize rememberMeSwitch;
@synthesize loginButton;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((UITableView *)self.view).backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.jpg"]];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setRememberMeSwitch:nil];
    [self setLoginButton:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return usernameCell;
    } else if (indexPath.row == 1) {
        return passwordCell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                       reuseIdentifier:@"RememberMeCell"];
        cell.textLabel.text = NSLocalizedString(@"Remember Me", nil);
        cell.accessoryView = rememberMeSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        [passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    [((UITableView *)self.view) scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                                      atScrollPosition:UITableViewScrollPositionTop 
                                              animated:YES];
}

#pragma mark - User actions

- (IBAction)performLogin:(id)sender 
{
    if (self.usernameField.text && ![self.usernameField.text isBlank] && self.passwordField.text && ![self.passwordField.text isBlank]) {
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
        [self authenticate];
    }
}

- (void)authenticate
{
    if (![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    DTActivityIndicatorView *activityIndicator = [[DTActivityIndicatorView alloc] init];
    [activityIndicator show];
    
    NSString *username = [usernameField.text strip];
    NSString *password = [[passwordField.text sha1] hexString];
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
        DTResponse *response = [DTConnection validateUsername:username password:password];
        if (![FN3ApiStatus instance].isActive) {
            // API version is invalid, do nothing, it will automatically prompt
        } else if (response.isSuccess) {
            DTCredentials *credentials = [DTCredentials instance];
            
            if ([credentials.username compare:username options:NSCaseInsensitiveSearch] != NSOrderedSame) {
                // user has logged in as a different user, treat it like a logout
                DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate clearUserData];
                
                // clear the token
                [[NSOperationQueue networkQueue] addOperations:[NSArray arrayWithObject:[[DTPushTokenOperation alloc] initWithToken:nil]] 
                                             waitUntilFinished:YES];
            }
            
            BOOL newUser = NO;
            DTPersistentStore *store = [[DTPersistentStore alloc] init];
            DTSettings *settings = [DTSettings settingsWithUserName:username 
                                                          inContext:store.managedObjectContext];
            if (!settings) {
                settings = [DTSettings createSettingsInContext:store.managedObjectContext];
                settings.userName = usernameField.text;
                [store save];
                
                newUser = YES;
            }
            
            // store the credentials
            credentials.username = username;
            credentials.password = password;
            if (rememberMeSwitch.on) {
                [credentials storeInKeychain];
            }
            [DTCredentials instance].isValid = YES;
            
            if (newUser) {
                // get the equipment list up front before showing the next 
                // screen to the user
                DTResponse *list = [DTConnection getTo:FN3APIEquipmentList parameters:nil];
                if (list.isSuccess) {
                    [[[DTEquipmentParser alloc] initWithGroupsResponse:nil listResponse:list.data] main];
                }
            }
        
            [(DTAppDelegate *)[UIApplication sharedApplication].delegate requestPushNotificationToken];
            [[NSOperationQueue networkQueue] addNetworkOperation:[[DTLoadDataOperation alloc] init]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [self onAuthenticationSuccess:response isNewUser:newUser];
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [self onAuthenticationFailure:response];
            }];
        }
    }];
    op.completionBlock = ^(void) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            [activityIndicator dismiss];
        }];
    };
    
    [[NSOperationQueue networkQueue] addOperation:op];
}

- (void)onAuthenticationSuccess:(DTResponse *)response isNewUser:(BOOL)isNewUser
{
    if (isNewUser) {
        // reset the state of the tabs
        UITabBarController *tabController = (UITabBarController *)self.presentingViewController;
        for (UIViewController *c in tabController.viewControllers) {
            if ([c isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController *)c;
                [nav popToRootViewControllerAnimated:NO];
                
                // reset the root controller if the root controller is not the
                // first controller (eg, it's an equipment group controller)
                if (nav.viewControllers.count > 1) {
                    [nav popViewControllerAnimated:NO];
                    [nav popToRootViewControllerAnimated:NO];
                }
            }
        }
        // select the first tab
        [tabController setSelectedIndex:0];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onAuthenticationFailure:(DTResponse *)response
{
    if ([FN3ApiStatus instance].isActive) {
        if (response.statusCode == 401) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Your username or password is incorrect.", nil)
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"An Error occurred", nil)
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
