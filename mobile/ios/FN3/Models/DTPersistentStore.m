//
//  PersistentStore.m
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import "DTPersistentStore.h"
#import "DTAppDelegate.h"

@implementation DTPersistentStore

@synthesize persistentStoreCoordinator;

static NSPersistentStoreCoordinator *__persistentStoreCoordinator = nil;
static NSManagedObjectModel *__managedObjectModel = nil;

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
+ (NSManagedObjectModel *)managedObjectModel
{
    @synchronized([DTPersistentStore class]) 
    {
        if (!__managedObjectModel) {
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FN3" withExtension:@"momd"];
            __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        }
        
        return __managedObjectModel;
    }
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized([DTPersistentStore class])
    {
        if (!__persistentStoreCoordinator) {
            NSURL *appDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *storeURL = [appDir URLByAppendingPathComponent:@"fn3.sqlite"];
            
            NSError *error = nil;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
            {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 
                 Typical reasons for an error here include:
                 * The persistent store is not accessible;
                 * The schema for the persistent store is incompatible with current managed object model.
                 Check the error message to determine what the actual problem was.
                 
                 
                 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
                 
                 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
                 * Simply deleting the existing store:
                 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
                 
                 * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
                 
                 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
                 
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
        return __persistentStoreCoordinator;
    }
}

+ (DTPersistentStore *)defaultStore
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        persistentStoreCoordinator = [DTPersistentStore persistentStoreCoordinator];
    }
    return self;
}

- (void)dealloc
{
    managedObjectContext = nil;
    persistentStoreCoordinator = nil;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (!managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
            [managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
            [managedObjectContext setStalenessInterval:0];
            [managedObjectContext setUndoManager:nil];
        }
    }
    
    return managedObjectContext;
}

- (BOOL)hasChanges
{
    return self.managedObjectContext.hasChanges;
}

- (NSSet *)updatedObjectIds
{
    NSSet *updatedObjects = [self.managedObjectContext updatedObjects];
    NSMutableSet *ids = [[NSMutableSet alloc] initWithCapacity:[updatedObjects count]];
    for (NSManagedObject *mo in updatedObjects) {
        [ids addObject:[mo objectID]];
    }
    return ids;
}

- (BOOL)save
{
    BOOL saved = NO;
    
    NSError *error = nil;
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context != nil && [context hasChanges]) {
        if ([context save:&error]) {
            saved = YES;
        } else {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return saved;
}

@end
