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
- (NSArray *)fetchLocalTaskLists;
- (NSManagedObject *)fetchLocalTaskListWithId:(NSString *)taskListId;
- (void)processServerTasks:(NSArray *)serverTasks fromTaskList:(GTLTasksTaskList *)serverTaskList;
- (NSArray *)fetchLocalTasksFromTaskList:(NSString *)taskListId;
- (NSManagedObject *)fetchLocalTaskWithId:(NSString *)taskId;

@end


int const kDefaultSyncInterval = 60;


@implementation GTSyncManager

@synthesize isSyncing = _isSyncing;
@synthesize isRepeating = _isRepeating;
@synthesize delayInSeconds = _delayInSeconds;
@synthesize tasksService = _tasksService;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;

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

- (GTLServiceTasks *)tasksService {
    if (!_tasksService) {
        _tasksService = [[GTLServiceTasks alloc] init];
        _tasksService.shouldFetchNextPages = YES;
        _tasksService.retryEnabled = YES;
    }
    return _tasksService;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self.dataSource persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [self.delegate presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
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
                              [self.delegate presentError:error];
                          } else {
                              [self processServerTaskLists:taskLists];
                          }
                      }];
        syncStarted = YES;
    }
    
    return syncStarted;
}

- (void)processServerTaskLists:(GTLTasksTaskLists *)serverTaskLists {
    
    NSMutableArray *localTaskLists = [NSMutableArray arrayWithArray:[self fetchLocalTaskLists]];
    
    if (serverTaskLists) {
        for (GTLTasksTaskList *serverTaskList in serverTaskLists) {
            NSManagedObject *localTaskList = [self fetchLocalTaskListWithId:serverTaskList.identifier];
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

- (NSArray *)fetchLocalTaskLists {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
//    [fetchRequest setResultType:NSDictionaryResultType];
//    [fetchRequest setReturnsDistinctResults:YES];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"id"]];
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self.delegate presentError:error];
    }
    return taskLists;
}

- (NSManagedObject *)fetchLocalTaskListWithId:(NSString *)taskListId {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"TaskList" inManagedObjectContext:self.managedObjectContext]];
    if (taskListId && taskListId.length > 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id='%@'", taskListId]];
    }
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (taskLists.count > 0 && !error) {
        return [taskLists objectAtIndex:0];
    } else if (error) {
        [self.delegate presentError:error];
    }
    return nil;
}

- (void)processServerTasks:(NSArray *)serverTasks fromTaskList:(GTLTasksTaskList *)serverTaskList {
    
    NSMutableArray *localTasks = [NSMutableArray arrayWithArray:[self fetchLocalTasksFromTaskList:serverTaskList.identifier]];
    
    for (GTLTasksTask *serverTask in serverTasks) {
        NSManagedObject *localTask = [self fetchLocalTaskWithId:serverTask.identifier];
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

- (NSArray *)fetchLocalTasksFromTaskList:(NSString *)taskListId {
    return [[self fetchLocalTaskListWithId:taskListId] valueForKey:@"tasks"];
}

- (NSManagedObject *)fetchLocalTaskWithId:(NSString *)taskId {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id='%@'", taskId]];
	NSError *error = nil;
    NSArray *taskLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (taskLists.count > 0 && !error) {
        return [taskLists objectAtIndex:0];
    } else if (error) {
        [self.delegate presentError:error];
    }
    return nil;
}

@end
