//
//  LocalTaskManager.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/26/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <TargetConditionals.h>

#import "LocalTaskManager.h"

#import "AppDelegate.h"
#import "GTSyncManager.h"
#import "NSThread-MCSMAdditions/NSThread+MCSMAdditions.h"

@interface LocalTaskManager ()
- (void)presentError:(NSError *)error;
@end

@implementation LocalTaskManager

@synthesize managedObjectContextConcurrencyType;
@synthesize managedObjectContext = _managedObjectContext;


- (id)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    self = [super init];
    if (self) {
        self.managedObjectContextConcurrencyType = concurrencyType;
    }
    return self;
}

#pragma mark - Local task list methods

- (NSArray *)taskLists {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
    NSArray *managedTaskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self presentError:error];
        return nil;
    }
    return managedTaskLists;
}

- (GTaskMasterManagedTaskList *)taskListWithId:(NSString *)taskListId {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
    if (taskListId && taskListId.length > 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier==%@", taskListId]];
    }
	NSError *error = nil;
    NSArray *managedTaskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self presentError:error];
    } else if (managedTaskLists.count == 1) {
        return [managedTaskLists objectAtIndex:0];
    }
    return nil;
}

- (GTaskMasterManagedTaskList *)newTaskListWithTitle:(NSString *)title {
    DLog(@"Create new local task list: '%@'\n", title);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskList"
                                              inManagedObjectContext:self.managedObjectContext];
    GTaskMasterManagedTaskList *newTaskList = [[GTaskMasterManagedTaskList alloc] initWithEntity:entity
                                                                  insertIntoManagedObjectContext:self.managedObjectContext];
    [newTaskList setTitle:title];
    [self saveContext];
    
    return newTaskList;
}

- (void)flagTaskListForRemoval:(GTaskMasterManagedTaskList *)localTaskList {
    [localTaskList setGTDeleted:[NSNumber numberWithBool:YES]];
    localTaskList.gTUpdated = [NSDate date];
    [[GTSyncManager sharedInstance] removeTaskList:localTaskList];
}


#pragma mark - Server task list methods

- (void)updateManagedTaskList:(GTaskMasterManagedTaskList *)managedTaskList withServerTaskList:(GTLTasksTaskList *)serverTaskList {
    managedTaskList.etag = serverTaskList.ETag;
    managedTaskList.identifier = serverTaskList.identifier;
    managedTaskList.selflink = serverTaskList.selfLink;
    managedTaskList.synced = serverTaskList.updated.date;
    managedTaskList.title = serverTaskList.title;
    managedTaskList.gTUpdated = serverTaskList.updated.date;
    [self saveContext];
}

- (void)addTaskList:(GTLTasksTaskList *)serverTaskList {
    
    DLog(@"Add new local task list from server: '%@'\n", serverTaskList.title);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskList"
                                              inManagedObjectContext:self.managedObjectContext];
    GTaskMasterManagedTaskList *taskList = [[GTaskMasterManagedTaskList alloc] initWithEntity:entity 
                                                               insertIntoManagedObjectContext:self.managedObjectContext];
    [self updateManagedTaskList:taskList withServerTaskList:serverTaskList];
}

- (void)updateTaskList:(GTLTasksTaskList *)serverTaskList {
    
    DLog(@"Update local task list from server: '%@'\n", serverTaskList.title);
    
    GTaskMasterManagedTaskList *taskList = [self taskListWithId:serverTaskList.identifier];
    [self updateManagedTaskList:taskList withServerTaskList:serverTaskList];
}

- (void)removeTaskList:(GTaskMasterManagedTaskList *)localTaskList {
    if (localTaskList) {
        [self.managedObjectContext deleteObject:localTaskList];
        [self saveContext];
    }
}


#pragma mark - Local task methods

- (GTaskMasterManagedTask *)taskWithId:(NSString *)taskId {
    NSError *error = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier==%@", taskId]];
    NSArray *managedTaskObjs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [self presentError:error];
    } else if (managedTaskObjs.count > 0) {
        return [managedTaskObjs objectAtIndex:0];
    }
    
    return nil;
}

- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                  inTaskList:(GTaskMasterManagedTaskList *)taskList {
    
    return [self newTaskWithTitle:title andDueDate:nil inTaskList:taskList];
    
}

- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                      andDueDate:(NSDate *)dueDate
                                      inTaskList:(GTaskMasterManagedTaskList *)taskList {
    
    return [self newTaskWithTitle:title dueDate:dueDate andNotes:nil inTaskList:taskList];
    
}

- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                         dueDate:(NSDate *)dueDate
                                        andNotes:(NSString *)notes
                                      inTaskList:(GTaskMasterManagedTaskList *)taskList {
    
    DLog(@"Creating new local task: '%@' in list: '%@'\n", title, taskList.title);
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    GTaskMasterManagedTask *newTask = [[GTaskMasterManagedTask alloc] initWithEntity:entity
                                                   insertIntoManagedObjectContext:self.managedObjectContext];
    newTask.title = title;
    newTask.due = dueDate;
    newTask.notes = notes;
    newTask.tasklist = taskList;
    
    taskList.gTUpdated = [NSDate date];
    
    [self saveContext];
    
    return newTask;
    
}

- (void)toggleFlags:(GTaskMasterManagedTaskFlag)flags forTask:(GTaskMasterManagedTask *)task {
    
    NSUInteger mask = 0x4;
    BOOL updated = NO;
    do {
        switch (flags & mask) {
            case kTaskFlagCompleted:
                if ([task.status isEqualToString:TASK_STATUS_INCOMPLETE]) {
                    task.status = TASK_STATUS_COMPLETE;
                    task.completed = [NSDate date];
                    updated = YES;
                } else if ([task.status isEqualToString:TASK_STATUS_COMPLETE]) {
                    task.status = TASK_STATUS_INCOMPLETE;
                    task.completed = nil;
                    updated = YES;
                }
                break;
                
            case kTaskFlagHidden:
                task.hidden = [NSNumber numberWithBool:!task.hidden.boolValue];
                updated = YES;
                break;
                
            case kTaskFlagDeleted:
                task.gTDeleted = [NSNumber numberWithBool:!task.gTDeleted.boolValue];
                updated = YES;
                break;
                
            default:
                break;
        }
        mask = mask >> 1;
    } while (mask > 0);
    
    if (updated) {
        task.gTUpdated = [NSDate date];
    }
    
    [self saveContext];
}


#pragma mark - Server task methods

- (void)updateManagedTask:(GTaskMasterManagedTask *)managedTask withServerTask:(GTLTasksTask *)serverTask {
    managedTask.completed = serverTask.completed.date;
    managedTask.gTDeleted = (serverTask.deleted == nil ? [NSNumber numberWithBool:NO] : serverTask.deleted);
    managedTask.due = serverTask.due.date;
    managedTask.etag = serverTask.ETag;
    managedTask.hidden = (serverTask.hidden == nil ? [NSNumber numberWithBool:NO] : serverTask.hidden);
    managedTask.identifier = serverTask.identifier;
    managedTask.notes = serverTask.notes;
    managedTask.position = serverTask.position;
    managedTask.selflink = serverTask.selfLink;
    managedTask.status = serverTask.status;
    managedTask.synced = serverTask.updated.date;
    managedTask.title = serverTask.title;
    managedTask.gTUpdated = serverTask.updated.date;
    
    NSString *parentTaskId = serverTask.parent;
    if (parentTaskId) {
        GTaskMasterManagedTask *parentTask = [self taskWithId:parentTaskId];
        managedTask.parent = parentTask;
    }
    
    [self saveContext];
}

- (void)addTask:(GTLTasksTask *)serverTask toList:(NSString *)taskListId {
    DLog(@"Adding new local task from server: '%@'\n", serverTask.title);
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    GTaskMasterManagedTask *task = [[GTaskMasterManagedTask alloc] initWithEntity:entity
                                                   insertIntoManagedObjectContext:self.managedObjectContext];
    task.tasklist = [self taskListWithId:taskListId];
    [self updateManagedTask:task withServerTask:serverTask];
}

- (void)updateTask:(GTLTasksTask *)serverTask {
    DLog(@"Updating local task from server: '%@'\n", serverTask.title);
    GTaskMasterManagedTask *task = [self taskWithId:serverTask.identifier];
    [self updateManagedTask:task withServerTask:serverTask];
}


#pragma mark - Utility methods

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (void)saveContext {
    
    [self.managedObjectContext performBlockAndWait:^{
        
        DLog(@"Saving managedObjectContext");
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            
#if !TARGET_OS_IPHONE
            if (![managedObjectContext commitEditing]) {
                DLog(@"Unable to commit editing before saving");
            }
#endif
            
            if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
                DLog(@"Unresolved error saving context: %@, %@", error, [error userInfo]);
                [self presentError:error];
                //            abort();
            }
        }
        
        if (!error && managedObjectContext.parentContext) {
            [managedObjectContext.parentContext performBlock:^{
                
                NSError *err;
                if (![managedObjectContext.parentContext save:&err]) {
                    NSLog(@"Unresolved error saving parent context: %@, %@", err, [err userInfo]);
                    [self presentError:err];
                }
                
            }];
        }
        
    }];
}

- (void)presentError:(NSError *)error {
#if TARGET_OS_IPHONE
#pragma mark TODO: Present error
#else
    [[NSApplication sharedApplication] presentError:error];
#endif
}


#pragma mark - Core Data stack

// Returns the directory the application uses to store the Core Data store file.
+ (NSURL *)applicationStoreDirectory {
#if TARGET_OS_IPHONE
    return [(AppDelegate *)[UIApplication sharedApplication].delegate applicationDocumentsDirectory];
#else
    return [(AppDelegate *)[NSApplication sharedApplication].delegate applicationFilesDirectory];
#endif
}

// Creates if necessary and returns the managed object model for the application.
+ (NSManagedObjectModel *)sharedManagedObjectModel {
    
    __strong static NSManagedObjectModel *_sharedManagedObjectModel = nil;
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GTaskMaster" withExtension:@"momd"];
        _sharedManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
    });
    
    return _sharedManagedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator {
    
    __strong static NSPersistentStoreCoordinator * _sharedPersistentStoreCoordinator = nil;
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        
#if TARGET_OS_IPHONE
        {
            NSURL *storeURL = [[LocalTaskManager applicationStoreDirectory] URLByAppendingPathComponent:@"GTaskMaster.sqlite"];
            
#if (WIPE_LOCAL_TASKS_DB_ON_LAUNCH)
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
#endif
            
            NSError *error = nil;
            _sharedPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[LocalTaskManager sharedManagedObjectModel]];
            if (![_sharedPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
                DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                
//                abort();
                _sharedPersistentStoreCoordinator = nil;
            }
        }
#else
        {
            NSManagedObjectModel *mom = [LocalTaskManager sharedManagedObjectModel];
            if (mom) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *applicationFilesDirectory = [LocalTaskManager applicationStoreDirectory];
                NSError *error = nil;
                
                NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
                
                BOOL shouldInitPersistentStoreCoordinator = YES;
                if (properties) {
                    if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
                        // Customize and localize this error.
                        NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
                        
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
                        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
                        
                        [[NSApplication sharedApplication] presentError:error];
                        shouldInitPersistentStoreCoordinator = NO;
                    }
                } else {
                    BOOL ok = NO;
                    if ([error code] == NSFileReadNoSuchFileError) {
                        ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
                    }
                    if (!ok) {
                        [[NSApplication sharedApplication] presentError:error];
                        shouldInitPersistentStoreCoordinator = NO;
                    }
                }
                
                if (shouldInitPersistentStoreCoordinator) {
                    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"GTaskMaster.storedata"];
                    
#if (WIPE_LOCAL_TASKS_DB_ON_LAUNCH)
                    [fileManager removeItemAtURL:url error:nil];
#endif
                    
                    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
                    if ([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
                        _sharedPersistentStoreCoordinator = coordinator;
                    } else {
                        [[NSApplication sharedApplication] presentError:error];
                    }
                }
                
            } else {
                DLog(@"No model to generate a store from");
                
            }
        }
#endif
        
    });
    
    return _sharedPersistentStoreCoordinator;
}

+ (NSManagedObjectContext *)sharedManagedObjectContext {
    
    __strong static NSManagedObjectContext *_sharedManagedObjectContext = nil;
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        
        NSPersistentStoreCoordinator *coordinator = [LocalTaskManager sharedPersistentStoreCoordinator];
        if (coordinator != nil) {
            _sharedManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_sharedManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
    });
    
    return _sharedManagedObjectContext;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        if (self.managedObjectContextConcurrencyType) {
            if (self.managedObjectContextConcurrencyType == NSMainQueueConcurrencyType) {
                _managedObjectContext = [LocalTaskManager sharedManagedObjectContext];
            } else {
                _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:self.managedObjectContextConcurrencyType];
                [_managedObjectContext setParentContext:[LocalTaskManager sharedManagedObjectContext]];
            }
        }
    }
    
    return _managedObjectContext;
}

@end
