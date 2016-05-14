//
//  CoreDataUtils.h
//  CBCSports
//
//  Created by Milos Jovanovic on 2015-05-01.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import "CoreDataUtils.h"

static NSManagedObjectContext *ManagedObjectContextForMainThread = nil;
static NSManagedObjectModel *SharedManagedObjectModel = nil;
static NSPersistentStoreCoordinator *SharedStoreCoordinator = nil;
static dispatch_once_t *onceToken;

@implementation CoreDataUtils

#pragma mark - Core Data stack

+ (void)resetContext:(NSManagedObjectContext*)context
{
    if (context != nil) {
        NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
        for(NSEntityDescription *entity in [model entities]) {
//            NSLog(@"Entity : %@", entity.name);
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            [request setResultType:NSManagedObjectIDResultType];
            NSError *error=nil;
            NSArray *results = [context executeFetchRequest:request error:&error];
//            NSLog(@"%lu objects in context\n\n", [results count]);
            if (error == nil && [results count] != 0) {
                [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    NSLog(@"Object :\n%@", obj);
                }];
            }
        }
        [context reset];
        [CoreDataUtils saveContext:context];
    }
}

+ (void) resetPersistentStore {
    NSError *error;
    ManagedObjectContextForMainThread = nil;
    

    if ([[CoreDataUtils persistentStoreCoordinator] persistentStores].count ) {
        NSPersistentStore *storeToRemove = [[[CoreDataUtils persistentStoreCoordinator] persistentStores] objectAtIndex:0];
        
        if (![[CoreDataUtils persistentStoreCoordinator] removePersistentStore:storeToRemove error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Delete the reference to non-existing store
    SharedStoreCoordinator = nil;
    *onceToken = 0;
}



+ (NSManagedObjectContext *)managedObjectContext
{
    static dispatch_once_t token;
    onceToken = &token;    // Store address of once_token
    dispatch_once(onceToken, ^{
        [CoreDataUtils persistentStoreCoordinator];
    });

    if (!SharedStoreCoordinator) {
        return nil;
    }
    static __weak NSThread* baseThread;
    NSThread* currentThread = [NSThread currentThread];
    if (!baseThread) {
        baseThread = currentThread;
    } else {
        if (![baseThread isEqual:currentThread]) {
            NSLog(@"!!");
        }
    }
    
    if (!ManagedObjectContextForMainThread) {
        ManagedObjectContextForMainThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [ManagedObjectContextForMainThread setPersistentStoreCoordinator:SharedStoreCoordinator];
    }
    return ManagedObjectContextForMainThread;
}


+ (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (SharedManagedObjectModel) {
        return SharedManagedObjectModel;
    }
        
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WalletModel" withExtension:@"momd"];
    SharedManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return SharedManagedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (SharedStoreCoordinator) {
        return SharedStoreCoordinator;
    }
    
    SharedStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LeagueWallet.sqlite"];
    NSLog(@"DB path: %@", storeURL);

    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    // to handle light weight migration of CoreData when DB schema changes
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    id store = [SharedStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    if (!store || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"ca.cbc.CBCSports" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
//    NSLog(@"Data Store: %@", SharedStoreCoordinator);
    
    return SharedStoreCoordinator;
}


#pragma mark - Core Data Saving support
+ (BOOL)saveContext:(NSManagedObjectContext*)context
{
    @try {
        NSError *error = nil;
        if (context != nil && !error) {
            if ([context hasChanges]) {
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    abort();
                    return NO;
                }
                return YES;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        return NO;
    }
}

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
        
    return [NSURL fileURLWithPath:documentPath];
    
    // The directory the application uses to store the Core Data store file. This code uses a 
    //return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ca.cbc.CBCSports"];
}

+ (NSURL*)storeURLWithToken:(NSString*)token {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[token stringByAppendingFormat:@".data"]];
}

@end

