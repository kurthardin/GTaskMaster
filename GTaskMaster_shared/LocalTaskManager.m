//
//  LocalTaskManager.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/26/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <TargetConditionals.h>

#import "LocalTaskManager.h"
#import "Defines.h"
#import "AppDelegate.h"

@interface LocalTaskManager ()
- (void)presentError:(NSError *)error;
@end

@implementation LocalTaskManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

- (NSArray *)taskLists {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self presentError:error];
    }
    return taskLists;
}

- (NSManagedObject *)taskListWithId:(NSString *)taskListId {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
    if (taskListId && taskListId.length > 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id='%@'", taskListId]];
    }
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (taskLists.count > 0 && !error) {
        return [taskLists objectAtIndex:0];
    } else if (error) {
        [self presentError:error];
    }
    return nil;
}

- (NSArray *)tasksForTaskList:(NSString *)taskListId {
    return [[self taskListWithId:taskListId] valueForKey:@"tasks"];
}

- (NSManagedObject *)taskWithId:(NSString *)taskId {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id='%@'", taskId]];
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (taskLists.count > 0 && !error) {
        return [taskLists objectAtIndex:0];
    } else if (error) {
        [self presentError:error];
    }
    return nil;
}

#pragma mark - Utility methods

- (void)presentError:(NSError *)error {
#if TARGET_OS_IPHONE
#pragma mark TODO: Present error
#else
    [[NSApplication sharedApplication] presentError:error];
#endif
}

#pragma mark - Core Data stack

// Returns the directory the application uses to store the Core Data store file.
- (NSURL *)applicationStoreDirectory {
#if TARGET_OS_IPHONE
    return [(AppDelegate *)[UIApplication sharedApplication].delegate applicationDocumentsDirectory];
#else
    return [(AppDelegate *)[NSApplication sharedApplication].delegate applicationFilesDirectory];
#endif
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GTaskMaster" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
#if TARGET_OS_IPHONE
{
    NSURL *storeURL = [[self applicationStoreDirectory] URLByAppendingPathComponent:@"GTaskMaster.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
#else
{
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationStoreDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"GTaskMaster.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
}
#endif
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [self presentError:error];
        return nil;
    } else {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        
#if !TARGET_OS_IPHONE
        if (![managedObjectContext commitEditing]) {
            NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
        }
#endif
        
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [self presentError:error];
//            abort();
        }
    }
}

@end
