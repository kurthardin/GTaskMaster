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

@property (nonatomic) BOOL isSyncing;
@property (nonatomic) BOOL isRepeating;
@property (nonatomic) double delayInSeconds;

@property (readonly, strong, nonatomic) LocalTaskManager *taskManager;
@property (readonly, strong, nonatomic) GTLServiceTasks *tasksService;

+ (GTSyncManager *)sharedInstance;

+ (BOOL)startSyncing;
+ (BOOL)startSyncingWithInterval:(double)seconds;
+ (void)setSyncDelay:(double)seconds;
+ (BOOL)syncNow;
+ (void)stopSyncing;

@end
