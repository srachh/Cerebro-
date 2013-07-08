//
//  DTUser.h
//  FN3
//
//  Created by David Jablonski on 3/15/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DTSettingsUpdate;


@class DTNotificationSetting;


@interface DTSettings : NSManagedObject

+ (DTSettings *)createSettingsInContext:(NSManagedObjectContext *)context;
+ (DTSettings *)settingsWithUserName:(NSString *)userName 
                           inContext:(NSManagedObjectContext *)context;
+ (DTSettings *)defaultSettingsInContext:(NSManagedObjectContext *)context;
+ (NSArray *)settingsInContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *notifications;

- (DTNotificationSetting *)settingForNotification:(NSString *)name;

@end
