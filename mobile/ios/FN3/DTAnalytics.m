//
//  DTAnalytics.m
//  FN3
//
//  Created by David Jablonski on 6/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTAnalytics.h"
#import "GANTracker.h"
#import "NSString+DTString.h"

@implementation DTAnalytics

static const NSInteger kGANDispatchPeriodSec = 10;
static const NSString * kDTANPathPrefix = @"/mobile/ios";

+ (DTAnalytics *)instance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *analyticsAccountId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"google.analytics.key"];
        [[GANTracker sharedTracker] startTrackerWithAccountID:analyticsAccountId
                                               dispatchPeriod:kGANDispatchPeriodSec
                                                     delegate:nil];
        NSLog(@"analytics started");
    }
    
    return self;
}

- (void)shutdown
{
    [[GANTracker sharedTracker] stopTracker];
}

- (void)trackEvent:(NSString *)event 
            action:(NSString *)action 
             label:(NSString *)label 
             value:(NSInteger)value
{
    NSError *error;
    if (![[GANTracker sharedTracker] trackEvent:event
                                         action:action
                                          label:label
                                          value:value
                                      withError:&error]) {
        NSLog(@"error in trackEvent: %@", [error localizedDescription]);
    }                                                                                                           
}

- (void)trackPageView:(NSString *)page
{
    page = [kDTANPathPrefix stringByAppendingString:page];
    
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:page withError:&error]) {
        NSLog(@"error in trackPageview: %@", [error localizedDescription]);
    }
    NSLog(@"tracked page view for %@", page);
}

- (void)trackViewController:(UIViewController *)controller
{
    NSMutableString *path = [[NSMutableString alloc] initWithString:@""];
    
    if (controller.tabBarController) {
        if (controller.tabBarController.selectedIndex == 0) {
            [path appendString:@"/equipment_tab"];
        } else if (controller.tabBarController.selectedIndex == 1) {
            [path appendString:@"/map_tab"];
        } else if (controller.tabBarController.selectedIndex == 2) {
            [path appendString:@"/alerts_tab"];
        } else if (controller.tabBarController.selectedIndex == 3) {
            [path appendString:@"/settings_tab"];
        } else {
            [path appendString:@"/help_tab"];
        }
    }
    
    if ([controller.navigationController visibleViewController] == controller) {
        for (UIViewController *c in [controller.navigationController viewControllers]) {
            NSString *page = [[[[c class] description] underscore] gsub:@"(^dt_)|(_view_controller$)" with:@""];
            [path appendFormat:@"/%@", page];
        }
    } else {
        NSString *page = [[[[controller class] description] underscore] gsub:@"(^dt_)|(_view_controller$)" with:@""];
        [path appendFormat:@"/%@", page];
    }

    [self trackPageView:path];
}

@end
