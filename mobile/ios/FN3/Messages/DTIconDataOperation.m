//
//  DTIconDataOperation.m
//  FN3
//
//  Created by David Jablonski on 5/29/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTIconDataOperation.h"
#import "DTImageData.h"
#import "DTConnection.h"
#import "DTPersistentStore.h"

@implementation DTIconDataOperation

- (id)initWithImagePaths:(NSSet *)_imagePaths notification:(NSNotification *)_notification
{
    if (self = [super init]) {
        imagePaths = _imagePaths;
        notification = _notification;
    }
    return self;
}

- (void)main
{
    DTPersistentStore *store = [[DTPersistentStore alloc] init];
    
    for (NSString *path in imagePaths) {
        if (self.isCancelled) {
            return;
        }
        
        DTImageData *imageData = [DTImageData imageDataForPath:path
                                                     inContext:store.managedObjectContext];
        if (!imageData) {
            NSData *data = [DTConnection getDataForPath:path];
            if (data) {
                imageData = [NSEntityDescription insertNewObjectForEntityForName:[[DTImageData class] description] 
                                                          inManagedObjectContext:store.managedObjectContext];
                imageData.path = path;
                imageData.data = data;
            }
        }
    }
    
    [store save];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
