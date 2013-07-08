//
//  DTGPIOType.h
//  FieldNET
//
//  Created by Loren Davelaar on 9/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DTGPIOType : NSManagedObject {
    UIImage *icon;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *typeDescription;
@property (nonatomic, retain) NSString *iconPath;
@property (nonatomic, readonly) UIImage *icon;

+ (DTGPIOType *)gpioTypeByType:(NSString *)type inContext:(NSManagedObjectContext *)context;

+ (NSArray *)gpioTypesInContext:(NSManagedObjectContext *)context;
@end
