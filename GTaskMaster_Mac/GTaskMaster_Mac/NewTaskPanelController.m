//
//  NewTaskPanelController.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/30/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "NewTaskPanelController.h"
#import "AppDelegate.h"
#import "GTSyncManager.h"

@implementation NewTaskPanelController

@synthesize taskList;
@synthesize titleTextField;
@synthesize notesTextField;

- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NewTaskPanel" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)dismiss {
    [super dismiss];
    [self.titleTextField setStringValue:@""];
    [self.notesTextField setStringValue:@""];
}

- (IBAction)handleCancelButton:(id)sender {
    [self dismiss];
}

- (IBAction)handleOkButton:(id)sender {
    if (self.taskList) {
        AppDelegate *appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
        
        NSString *title = self.titleTextField.stringValue;
        NSString *notes = self.notesTextField.stringValue;
        GTaskMasterManagedTask *newTask = [appDelegate.taskManager newTaskWithTitle:title
                                                                            dueDate:nil
                                                                           andNotes:notes
                                                                         inTaskList:self.taskList];
        [[GTSyncManager sharedInstance] addTask:newTask]; 
    } else {
        NSLog(@"Unable to create task, tasklist nil");
    }
    
    [self dismiss];
}

@end
