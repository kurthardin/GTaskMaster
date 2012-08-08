//
//  GTSyncManger.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "LocalTaskManager.h"
#import "GTLTasks.h"

@interface GTSyncManager : NSObject

@property (readonly, nonatomic) BOOL isSyncing;
@property (readonly, nonatomic) BOOL isRepeating;
@property (nonatomic) double delayInSeconds;

//@property (readonly, strong, nonatomic) NSThread *syncThread;
//@property (readonly, strong, nonatomic) NSRunLoop *syncRunloop;
@property (readonly, strong, nonatomic) NSTimer *syncTimer;

@property (readonly, strong, nonatomic) LocalTaskManager *taskManager;
@property (readonly, strong, nonatomic) GTLServiceTasks *tasksService;
@property (readonly, copy, nonatomic) NSMutableSet *activeServiceTickets;

+ (GTSyncManager *)sharedInstance;

+ (void)setSyncDelay:(double)seconds;
+ (BOOL)startSyncing;
+ (BOOL)startSyncingWithInterval:(double)seconds;
+ (BOOL)stopSyncing;
+ (BOOL)syncNow;

- (BOOL)addTaskList:(GTaskMasterManagedTaskList *)taskList;
- (BOOL)updateTaskList:(GTaskMasterManagedTaskList *)taskList;
- (BOOL)removeTaskList:(GTaskMasterManagedTaskList *)taskList;

- (BOOL)addTask:(GTaskMasterManagedTask *)task;
- (BOOL)updateTask:(GTaskMasterManagedTask *)task;

@end
