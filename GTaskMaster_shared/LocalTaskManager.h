//
//  LocalTaskManager.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/26/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalTaskManager : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSArray *)taskLists;
- (NSManagedObject *)taskListWithId:(NSString *)taskListId;

- (NSArray *)tasksForTaskList:(NSString *)taskListId;
- (NSManagedObject *)taskWithId:(NSString *)taskId;

- (void)saveContext;

@end
