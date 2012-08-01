//
//  GTaskMasterTask.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "GTaskMasterManagedTask.h"
#import "GTaskMasterManagedLink.h"
#import "AppDelegate.h"
#import "GTSyncManager.h"

@implementation GTaskMasterManagedTask

@dynamic completed;
@dynamic gTDeleted;
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
@dynamic gTUpdated;

@dynamic children;
@dynamic links;
@dynamic parent;
@dynamic tasklist;

- (NSString *)createLabelString {
    return [NSString stringWithFormat:@" %@ %@",
            ([self.status isEqualToString:TASK_STATUS_COMPLETE] ?
             @"√" : (self.gTDeleted.boolValue ? @"X" : (self.hidden.boolValue ? @"+" : @"-"))), self.title];
}

- (GTLTasksTask *)createGTLTasksTask {
    GTLTasksTask *task = [GTLTasksTask object];
    task.completed = [GTLDateTime dateTimeWithDate:self.completed timeZone:[NSTimeZone systemTimeZone]];
    task.due = [GTLDateTime dateTimeWithDate:self.due timeZone:[NSTimeZone systemTimeZone]];
    task.notes = self.notes;
    task.position = self.position;
    task.status = self.status;
    task.title = self.title;
#pragma mark TODO: Handle links
    return task;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
//    NSLog(@"[GTaskMastManagedTask setValue:%@ forKeyPath:%@]", value, keyPath);
    if ([keyPath isEqualToString:@"completed"] && [value isKindOfClass:[NSNumber class]]) {
        NSNumber *completed = value;
        if ((completed.boolValue && [self.status isEqualToString:TASK_STATUS_INCOMPLETE]) ||
            (!completed.boolValue && [self.status isEqualToString:TASK_STATUS_COMPLETE])) {
            
            [((AppDelegate *)[NSApp delegate]).taskManager toggleFlags:kTaskFlagCompleted forTask:self];
            [[GTSyncManager sharedInstance] updateTask:self];
        }
    } else {
        [super setValue:value forKeyPath:keyPath];
        
    }
}


@end
