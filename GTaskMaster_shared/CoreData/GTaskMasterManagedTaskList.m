//
//  GTaskMasterTaskList.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTaskMasterManagedTaskList.h"

@implementation GTaskMasterManagedTaskList

@dynamic gTDeleted;
@dynamic etag;
@dynamic identifier;
@dynamic selflink;
@dynamic synced;
@dynamic title;
@dynamic gTUpdated;

@dynamic tasks;

- (BOOL)isNew {
    return [self.synced isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]];
}

- (GTLTasksTaskList *)createGTLTasksTaskList {
    GTLTasksTaskList *tasklist = [GTLTasksTaskList object];
    tasklist.title = self.title;
    return tasklist;
}

@end
