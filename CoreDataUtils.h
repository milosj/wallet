//
//  CoreDataUtils.h
//  CBCSports
//
//  Created by Milos Jovanovic on 2015-05-01.
//  Copyright (c) 2015 ca.cbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataUtils : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (BOOL)saveContext:(NSManagedObjectContext*)context;
+ (void) resetPersistentStore;
+ (NSURL *)applicationDocumentsDirectory;
@end

