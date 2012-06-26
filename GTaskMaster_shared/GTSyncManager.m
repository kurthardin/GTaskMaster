//
//  GTSyncManger.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTSyncManager.h"
#import "NSThread-MCSMAdditions/NSThread+MCSMAdditions.h"

@interface GTSyncManager ()

- (BOOL)startRepeatedSyncing;
- (BOOL)cancelRepeatedSyncing;
- (BOOL)sync;

- (void)processServerTaskLists;
- (void)processServerTasksForTaskList:(GTLTasksTaskList *)serverTaskList;

- (GTLTasksTaskLists *)fetchServerTaskLists;
- (GTLTasksTasks *)fetchServerTasksForList:(GTLTasksTaskList *)taskList;

@end


int const kDefaultSyncInterval = 60;


@implementation GTSyncManager

@synthesize isSyncing = _isSyncing;
@synthesize isRepeating = _isRepeating;
@synthesize delayInSeconds = _delayInSeconds;
@synthesize syncThread = _syncThread;
@synthesize syncRunloop = _syncRunloop;
@synthesize syncTimer = _syncTimer;
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

+ (void)setSyncDelay:(double)seconds {
    GTSyncManager *syncer = [GTSyncManager sharedInstance];
    [syncer setDelayInSeconds:seconds];
    if (syncer.isRepeating) {
        [syncer cancelRepeatedSyncing];
        [syncer startRepeatedSyncing];
    }
}

+ (BOOL)startSyncing {
    return [[GTSyncManager sharedInstance] startRepeatedSyncing];;
}

+ (BOOL)startSyncingWithInterval:(double)seconds {
    GTSyncManager *syncer = [GTSyncManager sharedInstance];
    if (!syncer.isRepeating) {
        syncer.delayInSeconds = seconds;
        [syncer startRepeatedSyncing];
        return YES;
    }
    return NO;
}

+ (BOOL)stopSyncing {
    return [[GTSyncManager sharedInstance] cancelRepeatedSyncing];
}

+ (BOOL)syncNow {
    return [[GTSyncManager sharedInstance] sync];
}

- (id)init {
    self = [super init];
    if (self) {
        _isSyncing = NO;
        _isRepeating = NO;
        _delayInSeconds = kDefaultSyncInterval;
        _syncThread = [[NSThread alloc] initWithTarget:self selector:@selector(syncThreadMain) object:nil];
        [_syncThread start];
    }
    return self;
}

- (LocalTaskManager *)taskManager {
    if (_taskManager == nil) {
        void (^taskManagerInitBlock)() = ^{
            _taskManager = [[LocalTaskManager alloc] init];
        };
        [self.syncThread MCSM_performBlock:taskManagerInitBlock waitUntilDone:YES];
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

- (BOOL)startRepeatedSyncing {
    if (!self.isRepeating) {
        _syncTimer = [NSTimer timerWithTimeInterval:self.delayInSeconds target:self selector:@selector(sync) userInfo:nil repeats:YES];
        [self.syncRunloop addTimer:self.syncTimer forMode:NSDefaultRunLoopMode];
        _isRepeating = YES;
        return YES;
    }
    return NO;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if (self.isRepeating) {
//            [self repeatedSync];
//        }
//    });
//    return [self sync];
}

- (BOOL)cancelRepeatedSyncing {
    if (self.isRepeating) {
        if (self.syncTimer) {
            [self.syncTimer invalidate];
            _syncTimer = nil;
        }
        _isRepeating = NO;
        return YES;
    }
    return NO;
}

- (BOOL)sync {
    BOOL syncStarted = NO;
    
    if (!self.isSyncing) {
        _isSyncing = YES;
        [self performSelector:@selector(processServerTaskLists) onThread:self.syncThread withObject:nil waitUntilDone:NO];
        syncStarted = YES;
    }
    
    return syncStarted;
}

- (void)processServerTaskLists {
    GTLTasksTaskLists *serverTaskLists = [self fetchServerTaskLists];
    NSMutableArray *localTaskLists = [NSMutableArray arrayWithArray:[self.taskManager taskLists]];
    
    if (serverTaskLists) {
        for (GTLTasksTaskList *serverTaskList in serverTaskLists) {
            
            NSManagedObject *localTaskList = [self.taskManager taskListWithId:serverTaskList.identifier];
            NSDate *localModDate = nil;
            NSDate *serverModDate = nil;
            
            if (localTaskList == nil) {
#pragma mark TODO: Add list from server
            } else {
                serverModDate = serverTaskList.updated.date;
                localModDate = [localTaskList valueForKey:@"updated"];
            }
            
            if (localModDate == nil || [localModDate compare:serverModDate] != NSOrderedSame) {
                [self processServerTasksForTaskList:serverTaskList];
            }
            
            [localTaskLists removeObject:localTaskList];
        }
    }
    
    if (localTaskLists.count > 0) {
# pragma mark TODO: Add lists to server
    }
}

- (void)processServerTasksForTaskList:(GTLTasksTaskList *)serverTaskList {
    
    GTLTasksTasks *serverTasks = [self fetchServerTasksForList:serverTaskList];
    NSMutableArray *localTasks = [NSMutableArray arrayWithArray:[self.taskManager tasksForTaskList:serverTaskList.identifier]];
    
    for (GTLTasksTask *serverTask in serverTasks) {
        
        NSManagedObject *localTask = [self.taskManager taskWithId:serverTask.identifier];
        if (localTask == nil) {
#pragma mark TODO: Add task from server
        } else {
            
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
    }

    if (localTasks.count > 0) {
# pragma mark TODO: Add tasks to server
    }
}

- (id)synchronousFetch:(GTLQuery *)query {
    __block BOOL fetchComplete = NO;
    __block NSCondition *fetchCond = [[NSCondition alloc] init];
    __block id result;
    [NSThread MCSM_performBlockInBackground:^{
        [self.tasksService executeQuery:query
                      completionHandler:^(GTLServiceTicket *ticket,
                                          id fetchedResult, NSError *error) {
                          if (error) {
//                              [self.delegate presentError:error];
                          } else {
                              result = fetchedResult;
                          }
                          fetchComplete = YES;
                          [fetchCond signal];
                      }];
    }];
    [fetchCond lock];
    while (!fetchComplete) {
        [fetchCond wait];
    }
    [fetchCond unlock];
    return result;
}

- (GTLTasksTaskLists *)fetchServerTaskLists {
    return [self synchronousFetch:[GTLQueryTasks queryForTasklistsList]];
}

- (GTLTasksTasks *)fetchServerTasksForList:(GTLTasksTaskList *)taskList {
    return [self synchronousFetch:[GTLQueryTasks queryForTasklistsGetWithTasklist:taskList.identifier]];
}
     
#pragma mark - NSThread methods

- (void) syncThreadKeepAlive {
    [self performSelector:@selector(syncThreadKeepAlive) withObject:nil afterDelay:300];
}
     
- (void)syncThreadMain {
    // Add selector to prevent CFRunLoopRunInMode from returning immediately
    [self performSelector:@selector(imageSaverKeepAlive) withObject:nil afterDelay:300];
    BOOL done = NO;
    
    _syncRunloop = [NSRunLoop currentRunLoop];
    
    do {
        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
            done = YES;
    }
    while (!done);
}

@end
