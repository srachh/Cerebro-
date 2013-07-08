//
//  FN3Connection.h
//  FN3
//
//  Created by David Jablonski on 4/2/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FN3APISettings;
extern NSString * const FN3APIChangePassword;
extern NSString * const FN3APIPushToken;

extern NSString * const FN3APIGroupList;
extern NSString * const FN3APIEquipmentList;
extern NSString * const FN3APIEquipmentPoll;
extern NSString * const FN3APIEquipmentFeedback;
extern NSString * const FN3APIEquipmentDetail;
extern NSString * const FN3APIEquipmentOptions;
extern NSString * const FN3APIEquipmentHistory;

extern NSString * const FN3APITranslation;
extern NSString * const FN3APIAlerts;
extern NSString * const FN3APIConfiguration;

@class DTResponse;

@interface DTConnection : NSObject 

+ (BOOL)canSendMessages;

+ (NSData *)getDataForPath:(NSString *)path;

+ (DTResponse *)validateUsername:(NSString *)username password:(NSString *)password;
+ (DTResponse *)postTo:(NSString *)service parameters:(NSDictionary *)params;
+ (DTResponse *)getTo:(NSString *)service parameters:(NSDictionary *)params;
+ (NSString *)getHost;

@end
