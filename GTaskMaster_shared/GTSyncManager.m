//
//  GTSyncManger.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTSyncManager.h"

@interface GTSyncManager ()

- (BOOL)repeatedSync;
- (BOOL)sync;
- (void)processServerTaskLists:(GTLTasksTaskLists *)serverTaskLists;
- (void)processServerTasks:(NSArray *)serverTasks fromTaskList:(GTLTasksTaskList *)serverTaskList;

@end


int const kDefaultSyncInterval = 60;


@implementation GTSyncManager

@synthesize isSyncing = _isSyncing;
@synthesize isRepeating = _isRepeating;
@synthesize delayInSeconds = _delayInSeconds;
@synthesize taskManager = _taskManager;
@synthesize tasksService = _tasksService;

+ (GTSyncManager *)sharedInstance {
    __strong static id _sharedObject = nil;
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

+ (BOOL)startSyncing {
    return [[GTSyncManager sharedInstance] repeatedSync];
}

+ (BOOL)startSyncingWithInterval:(double)seconds {
    GTSyncManager *syncer = [GTSyncManager sharedInstance];
    syncer.delayInSeconds = seconds;
    return [syncer repeatedSync];
}

+ (void)setSyncDelay:(double)seconds {
    [GTSyncManager sharedInstance].delayInSeconds = seconds;
}

+ (BOOL)syncNow {
    return [[GTSyncManager sharedInstance] sync];
}

+ (void)stopSyncing {
    [GTSyncManager sharedInstance].isRepeating = NO;
}

- (id)init {
    self = [super init];
    if (self) {
        _isSyncing = NO;
        _isRepeating = NO;
        _delayInSeconds = kDefaultSyncInterval;
    }
    return self;
}

- (LocalTaskManager *)taskManager {
    if (_taskManager == nil) {
        _taskManager = [[LocalTaskManager alloc] init];
    }
    return _taskManager;
}

- (GTLServiceTasks *)tasksService {
    if (!_tasksService) {
        _tasksService = [[GTLServiceTasks alloc] init];
        _tasksService.shouldFetchNextPages = YES;
        _tasksService.retryEnabled = YES;
    }
    return _tasksService;
}

- (BOOL)repeatedSync {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.isRepeating) {
            [self repeatedSync];
        }
    });
    return [self sync];
}

- (BOOL)sync {
    BOOL syncStarted = NO;
    
    if (!self.isSyncing) {
        self.isSyncing = YES;
        [self.tasksService executeQuery:[GTLQueryTasks queryForTasklistsList]
                      completionHandler:^(GTLServiceTicket *ticket,
                                          id taskLists, NSError *error) {
                          // callback
                          if (error) {
//                              [self.delegate presentError:error];
                          } else {
                              [self processServerTaskLists:taskLists];
                          }
                      }];
        syncStarted = YES;
    }
    
    return syncStarted;
}

- (void)processServerTaskLists:(GTLTasksTaskLists *)serverTaskLists {
    
    NSMutableArray *localTaskLists = [NSMutableArray arrayWithArray:[self.taskManager taskLists]];
    
    if (serverTaskLists) {
        for (GTLTasksTaskList *serverTaskList in serverTaskLists) {
            NSManagedObject *localTaskList = [self.taskManager taskListWithId:serverTaskList.identifier];
            NSDate *serverModDate = serverTaskList.updated.date;
            NSDate *localModDate = [localTaskList valueForKey:@"updated"];
            if (localModDate == nil || [localModDate compare:serverModDate] != NSOrderedSame) {
# pragma mark TODO: Fetch tasks for list and process
            }
            [localTaskLists removeObject:localTaskList];
        }
    }
    
    if (localTaskLists.count > 0) {
# pragma mark TODO: Add list to server
    }
}

- (void)processServerTasks:(NSArray *)serverTasks fromTaskList:(GTLTasksTaskList *)serverTaskList {
    
    NSMutableArray *localTasks = [NSMutableArray arrayWithArray:[self.taskManager tasksForTaskList:serverTaskList.identifier]];
    
    for (GTLTasksTask *serverTask in serverTasks) {
        NSManagedObject *localTask = [self.taskManager taskWithId:serverTask.identifier];
        if (localTask == nil) {
#pragma mark TODO: Add task from server
        }
        NSDate *serverModDate = serverTask.updated.date;
        NSDate *localModDate = [localTask valueForKey:@"updated"];
        NSDate *localSyncDate = [localTask valueForKey:@"synced"];
        if ([localModDate compare:localSyncDate] == NSOrderedDescending) {
            if ([serverModDate compare:localSyncDate] == NSOrderedDescending) {
# pragma mark TODO: Resolve sync conflict
            } else {
# pragma mark TODO: Sync local changes with server
            }
        } else if ([serverModDate compare:localSyncDate] == NSOrderedDescending) {
            if ([localModDate compare:localSyncDate] == NSOrderedDescending) {
# pragma mark TODO: Resolve sync conflict
            } else {
# pragma mark TODO: Sync changes from server
            }
        }
        [localTasks removeObject:localTask];
    }

    if (localTasks.count > 0) {
# pragma mark TODO: Add task to server
    }
}

@end
