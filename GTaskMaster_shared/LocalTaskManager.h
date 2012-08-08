//
//  LocalTaskManager.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/26/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTLTasks.h"
#import "GTaskMasterManagedObjects.h"

typedef const enum {
    kTaskFlagCompleted  = 0x1,
    kTaskFlagHidden     = 0x2,
    kTaskFlagDeleted    = 0x4
} GTaskMasterManagedTaskFlag;

@interface LocalTaskManager : NSObject

@property (nonatomic) NSManagedObjectContextConcurrencyType managedObjectContextConcurrencyType;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

#pragma mark - Local task list methods

// Get local task list(s):
- (NSArray *)taskLists;                                                     // Gets all the local task lists
- (GTaskMasterManagedTaskList *)taskListWithId:(NSString *)taskListId;      // Gets the task list with the specified identifier

// Creates a new task list with the specified title:
- (GTaskMasterManagedTaskList *)newTaskListWithTitle:(NSString *)title;

// Remove a task list locally:
- (void)flagTaskListForRemoval:(GTaskMasterManagedTaskList *)localTaskList; // Flags specified task list for removal during next sync


#pragma mark - Server task list methods

// Handle changes to a task list from the server:
- (void)addTaskList:(GTLTasksTaskList *)serverTaskList;                     // Adds a new task list from server
- (void)updateTaskList:(GTLTasksTaskList *)serverTaskList;                  // Updates a task list with new data from server
- (void)updateManagedTaskList:(GTaskMasterManagedTaskList *)managedTaskList
           withServerTaskList:(GTLTasksTaskList *)serverTaskList;
- (void)removeTaskList:(GTaskMasterManagedTaskList *)localTaskList;         // Removes the specified task list


#pragma mark - Local task methods
// Get a local task:
- (GTaskMasterManagedTask *)taskWithId:(NSString *)taskId;                  // Gets the task with the specified identifier

// Create a new task with the specified information:
- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                  inTaskList:(GTaskMasterManagedTaskList *)taskList;
- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                  andDueDate:(NSDate *)dueDate
                                  inTaskList:(GTaskMasterManagedTaskList *)taskList;
- (GTaskMasterManagedTask *)newTaskWithTitle:(NSString *)title
                                     dueDate:(NSDate *)dueDate
                                    andNotes:(NSString *)notes
                                  inTaskList:(GTaskMasterManagedTaskList *)taskList;

// Toggle completed, hidden and deleted flags for a task.  Multiple flags can be passed in simultaneously by or'ing (|) them together.
- (void)toggleFlags:(GTaskMasterManagedTaskFlag)flags forTask:(GTaskMasterManagedTask *)task;


#pragma mark - Server task methods

// Handle changes to a task from the server:
- (void)addTask:(GTLTasksTask *)serverTask toList:(NSString *)taskListId;   // Adds a new task from server
- (void)updateTask:(GTLTasksTask *)serverTask;                              // Updates a task with new data from server
- (void)updateManagedTask:(GTaskMasterManagedTask *)managedTask
           withServerTask:(GTLTasksTask *)serverTask;


#pragma mark - Utility methods

- (void)saveContext;                                                        // Saves changes made in the current ManagedObjectContext
- (void)presentError:(NSError *)error;                                      // Presents a standard error to user

#pragma mark - CoreData Stack

+ (NSManagedObjectContext *)sharedManagedObjectContext;


@end
