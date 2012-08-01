//
//  LocalTaskManager.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/26/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTLTasks.h"
#import "GTaskMasterManagedObjects.h"

@interface LocalTaskManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//+ (NSManagedObjectModel *)sharedManagedObjectModel;
//+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator;

#pragma mark - TaskList methods
// Get a local task list:
- (NSArray *)taskLists;                                                     // Gets all the local task lists
- (GTaskMasterManagedTaskList *)taskListWithId:(NSString *)taskListId;      // Gets the task list with the specified identifier

// Handle a task list from server:
- (void)addTaskList:(GTLTasksTaskList *)serverTaskList;                     // Adds a new task list from server
- (void)updateTaskList:(GTLTasksTaskList *)serverTaskList;                  // Updates a task list with new data from server
- (void)updateManagedTaskList:(GTaskMasterManagedTaskList *)managedTaskList
           withServerTaskList:(GTLTasksTaskList *)serverTaskList;

// Handle task list removal:
- (void)flagTaskListForRemoval:(GTaskMasterManagedTaskList *)localTaskList; // Flags specified task list for removal during next sync
- (void)removeTaskList:(GTaskMasterManagedTaskList *)localTaskList;         // Removes the specified task list

// Creates a new task list with the specified title:
- (GTaskMasterManagedTaskList *)newTaskListWithTitle:(NSString *)title;


#pragma mark - Task methods
// Get a local task:
//- (NSArray *)tasksForTaskList:(NSString *)taskListId;                     // Gets all the tasks associated with the task list with the specified identifier
- (GTaskMasterManagedTask *)taskWithId:(NSString *)taskId;                  // Gets the task with the specified identifier

// Handle a task from server:
- (void)addTask:(GTLTasksTask *)serverTask toList:(NSString *)taskListId;   // Adds a new task from server
- (void)updateTask:(GTLTasksTask *)serverTask;                              // Updates a task with new data from server
- (void)updateManagedTask:(GTaskMasterManagedTask *)managedTask
           withServerTask:(GTLTasksTask *)serverTask;

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


#pragma mark - Utility methods
- (void)saveContext;                                                        // Saves changes made in the current ManagedObjectContext
- (void)presentError:(NSError *)error;                                      // Presents a standard error to user

@end
