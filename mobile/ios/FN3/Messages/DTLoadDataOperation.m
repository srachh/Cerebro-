//
//  DTLoadDataOperation.m
//  FN3
//
//  Created by David Jablonski on 5/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTLoadDataOperation.h"
#import "DTConnection.h"
#import "DTResponse.h"
#import "DTEquipmentParser.h"
#import "DTAlertsParser.h"
#import "DTConfigurationParser.h"
#import "DTSettingsParser.h"
#import "DTEquipmentDetailParser.h"
#import "NSOperationQueue+DTOperationQueue.h"

#import "DTCredentials.h"
#import "DTAppDelegate.h"
#import "NSArray+DTArray.h"

@implementation DTLoadDataOperation

- (void)showLoginPage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [(DTAppDelegate *)[UIApplication sharedApplication].delegate showLoginPageAnimated:YES];
    }];
}

- (void)main
{
    DTResponse *response = [DTConnection getTo:FN3APIGroupList parameters:nil];
    NSArray *equipmentList;
    if (!self.isCancelled && response.isSuccess) {
        DTResponse *listResponse = [DTConnection postTo:FN3APIEquipmentList parameters:nil];
        if (!self.isCancelled && listResponse.isSuccess) {
            equipmentList = listResponse.data;
            NSOperation *op = [[DTEquipmentParser alloc] initWithGroupsResponse:response.data 
                                                                   listResponse:equipmentList];
            [[NSOperationQueue parserQueue] addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
        } else if (response.isAuthenticationError) {
            [self showLoginPage];
            return;
        }
    } else if (response.isAuthenticationError) {
        [self showLoginPage];
        return;
    }
    
    if (!self.isCancelled) {
        response = [DTConnection getTo:FN3APIAlerts parameters:nil];
        if (!self.isCancelled && response.isSuccess) {
            NSOperation *op = [[DTAlertsParser alloc] initWithResponse:response.data];
            [[NSOperationQueue parserQueue] addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
        } else if (response.isAuthenticationError) {
            [self showLoginPage];
            return;
        }
    }

    if (!self.isCancelled) {
        response = [DTConnection getTo:FN3APIConfiguration parameters:nil];
        if (!self.isCancelled && response.isSuccess) {
            NSOperation *op = [[DTConfigurationParser alloc] initWithResponse:response.data];
            [[NSOperationQueue parserQueue] addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
        } else if (response.isAuthenticationError) {
            [self showLoginPage];
            return;
        }
    }
    
    if (!self.isCancelled) {
        response = [DTConnection getTo:FN3APISettings parameters:nil];
        if (!self.isCancelled && response.isSuccess) {
            NSOperation *op = [[DTSettingsParser alloc] initWithResponse:response.data
                                                                username:[DTCredentials instance].username];
            [[NSOperationQueue parserQueue] addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
        } else if (response.isAuthenticationError) {
            [self showLoginPage];
            return;
        }
    }

    for (NSArray *slice in [equipmentList slicesOfLength:10]) {
        if (self.isCancelled) {
            return;
        }
        
        NSArray *ids = [slice collect:^id(NSDictionary *equipment) {
            return [equipment objectForKey:@"id"];
        }];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ids, @"id", nil];
        
        DTResponse *response = [DTConnection getTo:FN3APIEquipmentDetail parameters:params];
        if (!self.isCancelled && response.isSuccess) {
            NSOperation *op = [[DTEquipmentDetailParser alloc] initWithResponse:response.data];
            [[NSOperationQueue parserQueue] addOperations:[NSArray arrayWithObject:op] waitUntilFinished:YES];
        } else if (response.isAuthenticationError) {
            [self showLoginPage];
            return;
        }
    }
}

@end
