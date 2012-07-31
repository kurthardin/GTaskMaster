//
//  TasksTableViewController.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/16/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "TasksTableViewController.h"
#import "AppDelegate.h"

@implementation TasksTableViewController

@synthesize tasklistsTableView;
@synthesize tasksTableView;

AppDelegate *_appDelegate;
NSWindow *_modalAddSheet;
NSString *_selectedTaskListId;

- (void)awakeFromNib {
    _appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
    
    NSArray *tasklists = [_appDelegate.taskManager taskLists];
    if (tasklists.count > 0) {
        GTaskMasterManagedTaskList *taskList = [tasklists objectAtIndex:0];
        _selectedTaskListId = taskList.identifier;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableViews) name:@"tasks_updated" object:nil];
}

- (void)refreshTableViews {
    [self.tasklistsTableView reloadData];
    [self.tasksTableView reloadData];
}

- (IBAction)addTaskList:(id)sender {
    
}

- (IBAction)addTask:(id)sender {
    if (_selectedTaskListId) {
        [_appDelegate.taskCreationPanelController setTaskListId:_selectedTaskListId];
        [_appDelegate.taskCreationPanelController show];
        
    } else {
        NSLog(@"Failed to add task, no task list selected...");
        
    }
}

#pragma mark - NSTableViewDelegate methods

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if ([tableView isEqualTo:self.tasklistsTableView]) {
        return YES;
    }
    
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.tasklistsTableView.selectedRow;
    if (selectedRow < 0) {
        _selectedTaskListId = nil;
    } else {
        NSArray *taskLists = [_appDelegate.taskManager taskLists];
        if (selectedRow < taskLists.count) {
            GTaskMasterManagedTaskList *taskList = [taskLists objectAtIndex:selectedRow];
            _selectedTaskListId = taskList.identifier;
        }
    }
    
    [self.tasksTableView reloadData];
}

#pragma mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    NSInteger rows = 0;
    if ([aTableView isEqualTo:tasklistsTableView]) {
        rows = [_appDelegate.taskManager taskLists].count;
    } else if ([aTableView isEqualTo:tasksTableView] && _selectedTaskListId) {
        GTaskMasterManagedTaskList *tasklist = [_appDelegate.taskManager taskListWithId:_selectedTaskListId];
        NSOrderedSet *tasks = tasklist.tasks;
        rows = tasks.count;
    } else {
        rows = 0;
    }
    return rows;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *title = @"FAIL";
    if ([aTableView isEqualTo:tasklistsTableView]) {
        title = ((GTaskMasterManagedTaskList *) [[_appDelegate.taskManager taskLists] objectAtIndex:rowIndex]).title;
    } else if ([aTableView isEqualTo:tasksTableView]) {
        GTaskMasterManagedTaskList *tasklist = [_appDelegate.taskManager taskListWithId:_selectedTaskListId];
        NSOrderedSet *tasks = tasklist.tasks;
        GTaskMasterManagedTask *task = [tasks objectAtIndex:rowIndex];
        title = [task createLabelString];
    }
    return title;
}

@end
