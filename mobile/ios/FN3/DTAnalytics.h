//
//  DTAnalytics.h
//  FN3
//
//  Created by David Jablonski on 6/13/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTAnalytics : NSObject

/* Returns the singleton instance. */
+ (DTAnalytics *)instance;


/* stops the analytic data collection */
- (void)shutdown;

/* Tracks the specified page view */
- (void)trackPageView:(NSString *)page;

/* 
 * Tracks an event.
 *   event  - The event to track
 *   action - The name of the action
 *   label  - A label for the event
 *   value  - A value, use -1 for no value
 */
- (void)trackEvent:(NSString *)event 
           action:(NSString *)action 
            label:(NSString *)label 
            value:(NSInteger)value;

- (void)trackViewController:(UIViewController *)controller;

@end
