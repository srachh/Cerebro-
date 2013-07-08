//
//  DTAppDelegate.h
//  FN3
//
//  Created by David Jablonski on 2/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DTAppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL didLaunch;
}

@property (strong, nonatomic) UIWindow *window;

- (void)requestPushNotificationToken;

- (void)clearUserData;
- (void)showLoginPageAnimated:(BOOL)animated;

@end
