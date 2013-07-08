//
//  DTChangePasswordViewController.h
//  FN3
//
//  Created by David Jablonski on 3/20/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTChangePasswordViewController : UITableViewController <UITextFieldDelegate> {
    NSString *username;
}

@property (nonatomic, retain) NSString *username;

- (IBAction)changePassword:(id)sender;

@end
