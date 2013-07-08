//
//  UIViewController+DTViewController.m
//  FN3
//
//  Created by David Jablonski on 3/23/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "UIViewController+DTViewController.h"

@implementation UIViewController (DTViewController)

- (BOOL)isCurrentlyDisplayed
{
    return [self isCurrentTab] && self.navigationController.topViewController == self;
}

- (BOOL)isCurrentTab
{
    return self.tabBarController.selectedViewController == self.navigationController;
}

@end
