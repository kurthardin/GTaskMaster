//
//  GTaskMasterTaskList.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTLTasks.h"

@class GTaskMasterManagedTask;

@interface GTaskMasterManagedTaskList : NSManagedObject

@property (nonatomic, retain) NSNumber *gTDeleted;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *selflink;
@property (nonatomic, retain) NSDate *synced;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *gTUpdated;

@property (nonatomic, retain) NSOrderedSet *tasks;

- (BOOL)isNew;
- (GTLTasksTaskList *)createGTLTasksTaskList;

@end

@interface GTaskMasterManagedTaskList (CoreDataGeneratedAccessors)

- (void)insertObject:(GTaskMasterManagedTask  *)value inTasksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTasksAtIndex:(NSUInteger)idx;
- (void)insertTasks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTasksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTasksAtIndex:(NSUInteger)idx withObject:(GTaskMasterManagedTask *)value;
- (void)replaceTasksAtIndexes:(NSIndexSet *)indexes withTasks:(NSArray *)values;
- (void)addTasksObject:(GTaskMasterManagedTask *)value;
- (void)removeTasksObject:(GTaskMasterManagedTask *)value;
- (void)addTasks:(NSOrderedSet *)values;
- (void)removeTasks:(NSOrderedSet *)values;

@end
