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

@end

int const kDefaultSyncInterval = 60;

@implementation GTSyncManager

@synthesize isSyncing;
@synthesize isRepeating;
@synthesize delayInSeconds;

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
        self.delayInSeconds = kDefaultSyncInterval;
    }
    return self;
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
    
    if (!isSyncing) {
#pragma mark TODO: Add Google Tasks API code
        
    }
    
    return syncStarted;
}

@end
