//
//  DTChangePasswordViewController.m
//  FN3
//
//  Created by David Jablonski on 3/20/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTChangePasswordViewController.h"
#import "DTAppDelegate.h"
#import "NSString+DTString.h"
#import "NSData+DTData.h"

#import "DTActivityIndicatorView.h"
#import "DTGreenButton.h"
#import "UIAlertView+DTAlertView.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTCredentials.h"

#import "DTAnalytics.h"

@implementation DTChangePasswordViewController

@synthesize username;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar_Logo.png"]];
    [(UITableView *)self.view setBackgroundView:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 
                                                                                               inSection:0]];
    [[cell viewWithTag:1] becomeFirstResponder];
    
    [[DTAnalytics instance] trackViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [(UITableView *)self.view indexPathForCell:cell];
    
    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row + 1 
                                               inSection:indexPath.section];
    UITableViewCell *nextCell = [(UITableView *)self.view cellForRowAtIndexPath:nextPath];
    if (nextCell) {
        [[nextCell viewWithTag:1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self changePassword:textField];
    }
    return YES;
}

- (NSString *)textForCellAtRow:(NSInteger)row inSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:indexPath];
    return [(UITextField *)[cell viewWithTag:1] text];
}

- (IBAction)changePassword:(id)sender
{
    if (![DTConnection canSendMessages]) {
        [[UIAlertView alertViewForNotConnectedToInternet] show];
        return;
    }
    
    NSString *currentPassword = [self textForCellAtRow:0 inSection:0];
    NSString *newPassword = [self textForCellAtRow:1 inSection:0];
    NSString *confirmNewPassword = [self textForCellAtRow:2 inSection:0];
    
    if (currentPassword && ![currentPassword isBlank] && newPassword && ![newPassword isBlank] && confirmNewPassword && ![confirmNewPassword isBlank]) {
        if ([[[currentPassword sha1] hexString] isEqualToString:[DTCredentials instance].password]) {
            if ([newPassword isEqualToString:confirmNewPassword]) {
                DTActivityIndicatorView *activityIndicator = [[DTActivityIndicatorView alloc] init];
                [activityIndicator show];

                NSOperation *op = [NSBlockOperation blockOperationWithBlock:^(void){
                    NSDictionary *params = [NSDictionary dictionaryWithObject:newPassword forKey:@"password"];

                    DTResponse *response = [DTConnection postTo:FN3APIChangePassword
                                                     parameters:params];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        if (response.isSuccess) {
                            [self.navigationController popViewControllerAnimated:YES];

                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:NSLocalizedString(@"Your password has been changed", nil)
                                                                           delegate:nil 
                                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            for (int i = 0; i < 3; i++) {
                                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                                UITableViewCell *cell = [(UITableView *)self.view cellForRowAtIndexPath:path];
                                UITextField *field = (UITextField *)[cell viewWithTag:1];
                                field.text = nil;
                                [field resignFirstResponder];
                            }

                            if (response.isAuthenticationError) {
                                [[UIAlertView alertViewForNotAuthenticated] show];
                                [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
                            } else {
                                [[UIAlertView alertViewForResponse:response 
                                                    defaultMessage:NSLocalizedString(@"Failed to change password.", nil)] show];
                            }
                        }
                    }];
                }];
                op.completionBlock = ^(void){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        [activityIndicator dismiss];
                    }];
                };
                [[NSOperationQueue networkQueue] addNetworkOperation:op];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"Password and confirmation password do not match.", nil)
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Current password is incorrect.", nil)
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
