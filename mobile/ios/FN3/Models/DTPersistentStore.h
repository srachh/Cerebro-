//
//  PersistentStore.h
//  FN3
//
//  Created by David Jablonski on 3/14/12.
//  Copyright (c) 2012 Client Resources Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DTPersistentStore : NSObject {
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

/* Returns the default store.  This should only be used in the main queue. */
+ (DTPersistentStore *)defaultStore;


/* Returns the NSManagedObjectContext for this store. */
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

/* Returns the application's NSPersistentStoreCoordinator. */
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) BOOL hasChanges;

/* 
 * Returns a set of NSManagedObjectID for all objects that have not been saved
 * to the store.
 */
- (NSSet *)updatedObjectIds;

/* commit any changes to the persistent store. */
- (BOOL)save;

@end
