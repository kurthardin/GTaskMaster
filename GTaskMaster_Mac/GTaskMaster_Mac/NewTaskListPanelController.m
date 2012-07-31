//
//  NewTaskListPanelController.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/31/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "NewTaskListPanelController.h"
#import "AppDelegate.h"
#import "GTSyncManager.h"

@implementation NewTaskListPanelController

@synthesize titleTextField;

- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NewTaskListPanel" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)dismiss {
    [super dismiss];
    [self.titleTextField setStringValue:@""];
}

- (IBAction)handleCancelButton:(id)sender {
    [self dismiss];
}

- (IBAction)handleOkButton:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
    
    NSString *title = self.titleTextField.stringValue;
    GTaskMasterManagedTaskList *newTaskList = [appDelegate.taskManager newTaskListWithTitle:title];
    [[GTSyncManager sharedInstance] addTaskList:newTaskList];
    
    [self dismiss];
}

@end
