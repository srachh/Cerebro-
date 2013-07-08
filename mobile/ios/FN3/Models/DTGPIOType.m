//
//  DTGPIOType.m
//  FieldNET
//
//  Created by Loren Davelaar on 9/21/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTGPIOType.h"
#import "NSArray+DTArray.h"
#import "DTImageData.h"

@implementation DTGPIOType

@dynamic type;
@dynamic typeDescription;
@dynamic iconPath;

+ (DTGPIOType *)gpioTypeByType:(NSString *)type inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    request.predicate = [NSPredicate predicateWithFormat:@"type = %@", type];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result.count == 0 ? nil : [result objectAtIndex:0];
    } else {
        @throw error;
    }
}

+ (NSArray *)gpioTypesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self description]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"typeDescription" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result) {
        return result;
    } else {
        @throw error;
    }
}

- (UIImage *)icon
{
    if (!icon) {
        if (self.iconPath) {
            DTImageData *imageData = [DTImageData imageDataForPath:self.iconPath 
                                                         inContext:self.managedObjectContext];
            if (imageData) {
                icon = [UIImage imageWithData:imageData.data];
            }
        }
        
        if (!icon) {
            icon = [UIImage imageNamed:@"io_help.png"];
        }
    }
    return icon;
}

- (CGSize)size
{
    CGSize imageSize = self.icon.size;
    
    // scale the image proportionatly such that the height and width is no more than max_size pixels
    CGFloat scale = 100.0 / MAX(imageSize.width, imageSize.height);
    return CGSizeMake(imageSize.width * scale, imageSize.height * scale);
}

@end
