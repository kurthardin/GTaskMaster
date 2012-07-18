//
//  GTaskMasterTask.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTaskMasterManagedTask.h"
#import "GTaskMasterManagedLink.h"

@implementation GTaskMasterManagedTask

@dynamic completed;
@dynamic deleted;
@dynamic due;
@dynamic etag;
@dynamic hidden;
@dynamic identifier;
@dynamic notes;
@dynamic position;
@dynamic selflink;
@dynamic status;
@dynamic synced;
@dynamic title;
@dynamic updated;

@dynamic children;
@dynamic links;
@dynamic parent;
@dynamic tasklist;

- (NSString *)createLabelString {
    return [NSString stringWithFormat:@" %@ %@",
            (self.completed ? @"√" : (self.deleted ? @"X" : (self.hidden ? @"+" : @"-"))), self.title];
}

- (GTLTasksTask *)createGTLTasksTask {
    GTLTasksTask *task = [GTLTasksTask object];
    task.completed = [GTLDateTime dateTimeWithDate:self.completed timeZone:[NSTimeZone systemTimeZone]];
    task.deleted = self.deleted;
    task.due = [GTLDateTime dateTimeWithDate:self.due timeZone:[NSTimeZone systemTimeZone]];
    task.hidden = self.hidden;
    task.notes = self.notes;
    task.position = self.position;
    task.status = self.status;
    task.title = self.title;
#pragma mark TODO: Handle links
    return task;
}


@end
