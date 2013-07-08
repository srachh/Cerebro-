//
//  DTSettingsParser.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTSettingsParser.h"
#import "DTPersistentStore.h"
#import "DTSettings.h"
#import "DTNotificationSetting.h"
#import "NSDictionary+DTDictionary.h"

@implementation DTSettingsParser

- (id)initWithResponse:(id)_response username:(NSString *)_username
{
    if (self = [super init]) {
        response = _response;
        username = _username;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    DTSettings *settings = [DTSettings settingsWithUserName:username
                                                  inContext:store.managedObjectContext];
    if (settings) {
        NSDictionary *data = [response dictionaryByRemovingNullVales];
        
        settings.email = [data objectForKey:@"email"];
        settings.phone = [data objectForKey:@"phone"];
        
        // re-create the notification settings
        for (DTNotificationSetting *notification in settings.notifications) {
            [store.managedObjectContext deleteObject:notification];
        }
        
        NSDictionary *alerts = [data objectForKey:@"alerts"];
        for (NSString *name in alerts) {
            DTNotificationSetting *notification = [DTNotificationSetting createNotificationSettingInContext:store.managedObjectContext];
            notification.name = name;
            notification.label = [[alerts objectForKey:name] objectForKey:@"label"];
            notification.on = [[alerts objectForKey:name] objectForKey:@"value"];
            notification.settings = settings;
        }
        
        [store save];
        [[NSNotificationCenter defaultCenter] postNotificationName:DTSettingsUpdate 
                                                            object:settings.userName];
    }
}

@end
