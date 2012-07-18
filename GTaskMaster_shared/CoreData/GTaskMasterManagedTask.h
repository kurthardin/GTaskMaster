//
//  GTaskMasterTask.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTLTasks.h"

@class GTaskMasterManagedTaskList;
@class GTaskMasterManagedLink;

@interface GTaskMasterManagedTask : NSManagedObject

@property (nonatomic, retain) NSDate *completed;
@property (nonatomic, retain) NSNumber *deleted;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) NSNumber *hidden;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *position;
@property (nonatomic, retain) NSString *selflink;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSDate *synced;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *updated;

#pragma mark - Relationships
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) NSOrderedSet *links;
@property (nonatomic, retain) GTaskMasterManagedTask *parent;
@property (nonatomic, retain) GTaskMasterManagedTaskList *tasklist;

#pragma mark - Utility methods
- (NSString *)createLabelString;
- (GTLTasksTask *)createGTLTasksTask;

@end

@interface GTaskMasterManagedTask (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(GTaskMasterManagedTask *)value;
- (void)removeChildrenObject:(GTaskMasterManagedTask *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)insertObject:(GTaskMasterManagedLink *)value inLinksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLinksAtIndex:(NSUInteger)idx;
- (void)insertLinks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLinksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLinksAtIndex:(NSUInteger)idx withObject:(GTaskMasterManagedLink *)value;
- (void)replaceLinksAtIndexes:(NSIndexSet *)indexes withLinks:(NSArray *)values;
- (void)addLinksObject:(GTaskMasterManagedLink *)value;
- (void)removeLinksObject:(GTaskMasterManagedLink *)value;
- (void)addLinks:(NSOrderedSet *)values;
- (void)removeLinks:(NSOrderedSet *)values;

@end
