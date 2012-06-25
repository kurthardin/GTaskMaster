//
//  GTSyncManger.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTSyncManagerDataSource, GTSyncManagerDelegate;

@interface GTSyncManager : NSObject

@property (nonatomic) BOOL isSyncing;
@property (nonatomic) BOOL isRepeating;
@property (nonatomic) double delayInSeconds;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<GTSyncManagerDataSource> dataSource;
@property (strong, nonatomic) id<GTSyncManagerDelegate> delegate;

+ (GTSyncManager *)sharedInstance;

+ (BOOL)startSyncing;
+ (BOOL)startSyncingWithInterval:(double)seconds;
+ (void)setSyncDelay:(double)seconds;
+ (BOOL)syncNow;
+ (void)stopSyncing;

@end

@protocol GTSyncManagerDataSource <NSObject>
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
@end

@protocol GTSyncManagerDelegate <NSObject>
- (void)presentError:(NSError *)error;
@end
