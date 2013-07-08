//
//  DTGeneralIO.m
//  FN3
//
//  Created by David Jablonski on 4/18/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTGeneralIO.h"
#import "DTEquipmentDataField.h"
#import "DTImageData.h"
#import "NSDictionary+DTDictionary.h"

@implementation DTGeneralIO

@dynamic enabled;
@dynamic type, iconPath, dataFields;

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
            icon = [UIImage imageNamed:@"io.png"];
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

- (void)parseGeneralData:(NSDictionary *)data
{
    if ([data objectForKey:@"type"] && [data objectForKey:@"type"] != [NSNull null]) {
        self.type = [data objectForKey:@"type"];
    }
    
    [super parseGeneralData:data];
}

- (void)parseIconData:(NSDictionary *)iconData
{
    id data = [iconData objectForKey:@"data"];
    if (data && data != [NSNull null]) {
        self.iconPath = [NSString stringWithFormat:@"/core/media/i/devices/%@", data];
    } else {
        self.iconPath = nil;
    }
}

- (void)parseDetailData:(NSDictionary *)message
{
    message = [message dictionaryByRemovingNullVales];
    
    self.enabled = [message objectForKey:@"enabled"];
    
    NSSet *oldFields = self.dataFields;
    [self removeDataFields:oldFields];
    for (DTEquipmentDataField *field in oldFields) {
        [self.managedObjectContext deleteObject:field];
    }
    
    NSMutableSet *newFields = [[NSMutableSet alloc] init];
    for (NSDictionary *d in [message objectForKey:@"data"]) {
        NSDictionary *values = [d dictionaryByRemovingNullVales];
        
        DTEquipmentDataField *field = [self fieldWithName:[values objectForKey:@"name"]];
        if (!field) {
            field = [NSEntityDescription insertNewObjectForEntityForName:[[DTEquipmentDataField class] description] 
                                                  inManagedObjectContext:self.managedObjectContext];
            field.name = [values objectForKey:@"name"];
            field.equipment = self;
        }
        
        field.value = [[values objectForKey:@"value"] description];
        field.uom = [values objectForKey:@"uom"];
        field.order = [NSNumber numberWithInt:newFields.count];
        
        [newFields addObject:field];
    }
    
    NSSet *deleteFields = [self.dataFields objectsPassingTest:^BOOL(id object, BOOL *stop) {
        return ![newFields containsObject:object];
    }];
    for (DTEquipmentDataField *field in deleteFields) {
        [self removeDataFieldsObject:field];
        [self.managedObjectContext deleteObject:field];
    }
}

@end
