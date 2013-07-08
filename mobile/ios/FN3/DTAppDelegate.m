//
//  DTAppDelegate.m
//  FN3
//
//  Created by David Jablonski on 2/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAppDelegate.h"
#import "DTPersistentStore.h"
#import "DTAlert.h"
#import "DTAuthenticationViewController.h"
#import "DTSettings.h"
#import "DTCredentials.h"
#import "DTTranslation.h"
#import "DTEquipmentGroup.h"
#import "DTEquipment.h"
#import "DTEquipmentHistory.h"
#import "DTConfiguration.h"
#import "DTImageData.h"
#import "DTGPIOType.h"

#import "NSOperationQueue+DTOperationQueue.h"
#import "DTLoadDataOperation.h"
#import "DTPushTokenOperation.h"

#import "DTAnalytics.h"

#import "DTConnection.h"
#import "DTResponse.h"
#import "DTAlertsParser.h"
#import "UIColor+DTColor.h"


@implementation DTAppDelegate

@synthesize window = _window;

#pragma mark - application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    didLaunch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateUnreadAlertCount) 
                                                 name:DTAlertUpdate 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateUnreadAlertCount) 
                                                 name:DTEquipmentAlertStatusUpdate
                                               object:nil];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:.78 green:.78 blue:.78 alpha:1]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [NSNumber numberWithInt:0], UITextAttributeTextShadowOffset,
      nil]
     forState:UIControlStateNormal];
    
    return YES;
}
static void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.jpg"]];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    background.frame = self.window.rootViewController.view.bounds;
    [self.window.rootViewController.view insertSubview:background atIndex:0];
    
    // center tab bar images
    UITabBarController *tabs = (UITabBarController *)self.window.rootViewController;
    for (UITabBarItem *item in tabs.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    
    [self updateUnreadAlertCount];
    
    if (didLaunch) {
        if ([DTSettings defaultSettingsInContext:[DTPersistentStore defaultStore].managedObjectContext]) {
            // user is not being remembered, have them log in
            if (![DTCredentials instance].isStoredInKeychain) {
                [self showLoginPageAnimated:NO];
            } else {
                [[NSOperationQueue networkQueue] addNetworkOperation:[[DTLoadDataOperation alloc] init]];
                [self requestPushNotificationToken];
            }
        } else {
            // user has never logged on before
            [self showLoginPageAnimated:NO];
        }
        
        didLaunch = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[DTAnalytics instance] shutdown];
}

#pragma mark - push notifications

- (void)requestPushNotificationToken
{
    NSLog(@"requesting notification token");
    
    UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"got device token for notifications: [%@]", [deviceToken description]);
    
    [[NSOperationQueue networkQueue] addOperation:[[DTPushTokenOperation alloc] initWithToken:deviceToken]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"device token failed: %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received notification");
    
    [[NSOperationQueue networkQueue] addOperationWithBlock:^(void){
        DTResponse *response = [DTConnection getTo:FN3APIAlerts parameters:nil];
        if (response.isSuccess) {
            [[NSOperationQueue parserQueue] addOperation:[[DTAlertsParser alloc] initWithResponse:response.data]];
        }
    }];
}

#pragma mark - login, logout

- (void)showLoginPageAnimated:(BOOL)animated
{
    [DTCredentials instance].isValid = NO;
    DTAuthenticationViewController *controller = [[DTAuthenticationViewController alloc]  initWithNibName:@"AuthenticationView" 
                                                                                                   bundle:nil];
    
    [self.window.rootViewController presentModalViewController:controller animated:animated];
}

- (void)clearUserData
{
    DTPersistentStore *ps = [[DTPersistentStore alloc] init];
    for (DTTranslation *t in [DTTranslation translationsInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:t];
    }
    for (DTEquipmentGroup *group in [DTEquipmentGroup equipmentGroupsInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:group];
    }
    for (DTEquipment *e in [DTEquipment equipmentInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:e];
    }
    for (DTEquipmentHistory *hist in [DTEquipmentHistory equipmentHistoryInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:hist];
    }
    for (DTConfiguration *config in [DTConfiguration configurationsInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:config];
    }
    for (DTImageData *data in [DTImageData imageDataInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:data];
    }
    for (DTSettings *settings in [DTSettings settingsInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:settings];
    }
    for (DTAlert *alert in [DTAlert alertsInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:alert];
    }
    
    for (DTGPIOType *gpioType in [DTGPIOType gpioTypesInContext:ps.managedObjectContext]) {
        [ps.managedObjectContext deleteObject:gpioType];
    }
    [ps save];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentGroupUpdate object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DTEquipmentUpdate object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DTAlertUpdate object:nil];
}

#pragma mark - unread alert badge

- (void)updateUnreadAlertCount
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    NSInteger unreadCount = 0;
    for (DTAlert *alert in [DTAlert alertsInContext:store.managedObjectContext]) {
        if (![alert.viewed boolValue]) {
            unreadCount++;
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
        UIViewController *c = [tab.viewControllers objectAtIndex:2];
        if (unreadCount == 0) {
            c.tabBarItem.badgeValue = nil;
        } else {
            c.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", unreadCount];
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
    }];
}

@end
