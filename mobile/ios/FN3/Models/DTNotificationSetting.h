//
//  DTNotificationSetting.h
//  FN3
//
//  Created by David Jablonski on 4/17/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTSettings;

@interface DTNotificationSetting : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * on;
@property (nonatomic, retain) DTSettings *settings;
@property (nonatomic, retain) NSString * label;

+ (DTNotificationSetting *)createNotificationSettingInContext:(NSManagedObjectContext *)context;

@end
