//
//  GTSyncManger.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LocalTaskManager.h"
#import "GTLTasks.h"

@interface GTSyncManager : NSObject

@property (readonly, nonatomic) BOOL isSyncing;
@property (readonly, nonatomic) BOOL isRepeating;
@property (nonatomic) double delayInSeconds;

@property (readonly, strong, nonatomic) NSThread *syncThread;
@property (readonly, strong, nonatomic) NSRunLoop *syncRunloop;
@property (readonly, strong, nonatomic) NSTimer *syncTimer;

@property (readonly, strong, nonatomic) LocalTaskManager *taskManager;
@property (readonly, strong, nonatomic) GTLServiceTasks *tasksService;

+ (GTSyncManager *)sharedInstance;

+ (void)setSyncDelay:(double)seconds;
+ (BOOL)startSyncing;
+ (BOOL)startSyncingWithInterval:(double)seconds;
+ (BOOL)stopSyncing;
+ (BOOL)syncNow;

@end
