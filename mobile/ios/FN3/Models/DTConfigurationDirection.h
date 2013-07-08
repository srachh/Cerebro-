//
//  DTConfigurationDirection.h
//  FieldNET
//
//  Created by Kevin on 9/10/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTConfiguration;

@interface DTConfigurationDirection : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) DTConfiguration *configuration;

@end
