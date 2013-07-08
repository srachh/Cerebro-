//
//  DTUser.m
//  FN3
//
//  Created by David Jablonski on 3/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSettings.h"
#import "DTNotificationSetting.h"

NSString * const DTSettingsUpdate = @"DTSettingsUpdate";


@implementation DTSettings

@dynamic userName;
@dynamic email;
@dynamic phone;
@dynamic notifications;

+ (DTSettings *)createSettingsInContext:(NSManagedObjectContext *)context
{
    return (DTSettings *)[NSEntityDescription insertNewObjectForEntityForName:[self description] 
                                                   inManagedObjectContext:context];
}

+ (DTSettings *)settingsWithUserName:(NSString *)userName 
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self description] 
                                   inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userName = %@", userName]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        return array.count == 0 ? nil : [array objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (DTSettings *)defaultSettingsInContext:(NSManagedObjectContext *)context
{
    NSArray *allSettings = [self settingsInContext:context];
    return allSettings.count == 0 ? nil : [allSettings objectAtIndex:0];
}

+ (NSArray *)settingsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self description] 
                                   inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array) {
        return array;
    } else {
        @throw error;
    }
}

- (DTNotificationSetting *)settingForNotification:(NSString *)name
{
    for (DTNotificationSetting *notification in self.notifications) {
        if ([notification.name isEqualToString:name]) {
            return notification;
        }
    }
    return nil;
}

@end
