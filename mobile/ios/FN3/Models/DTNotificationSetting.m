//
//  DTNotificationSetting.m
//  FN3
//
//  Created by David Jablonski on 4/17/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTNotificationSetting.h"
#import "DTSettings.h"


@implementation DTNotificationSetting

@dynamic name;
@dynamic on;
@dynamic settings;
@dynamic label;

+ (DTNotificationSetting *)createNotificationSettingInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                         inManagedObjectContext:context];
}

@end
