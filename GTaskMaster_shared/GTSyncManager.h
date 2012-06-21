//
//  GTSyncManger.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTSyncManager : NSObject {
    BOOL isSyncing;
    BOOL isRepeating;
    double delayInSeconds;
}

@property (nonatomic) BOOL isSyncing;
@property (nonatomic) BOOL isRepeating;
@property (nonatomic) double delayInSeconds;

+ (BOOL)startSyncing;
+ (BOOL)startSyncingWithInterval:(double)seconds;
+ (void)setSyncDelay:(double)seconds;
+ (BOOL)syncNow;
+ (void)stopSyncing;

@end
