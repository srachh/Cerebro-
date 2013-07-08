//
//  DTEquipmentNavigationController.m
//  FN3
//
//  Created by David Jablonski on 3/7/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTEquipmentGroupNavigationController.h"

@implementation DTEquipmentGroupNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)pushListViewController
{
    UIViewController *root = [self.viewControllers objectAtIndex:0];
    UITableView *tableView = (UITableView *)root.view;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [root performSegueWithIdentifier:@"SegueToRootScene" 
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (hasLoadedBefore) {
        if (self.viewControllers.count >= 2) {
            return [self popToViewController:[self.viewControllers objectAtIndex:1] 
                                    animated:animated];
        } else if (self.viewControllers.count == 1) {
            [self pushListViewController];
            return [[NSArray alloc] init];
        } else {
            return [[NSArray alloc] init];
        }
    } else {
        return [NSArray array];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!hasLoadedBefore) {
        [self pushListViewController];
    }
    
    hasLoadedBefore = YES;
}

@end
