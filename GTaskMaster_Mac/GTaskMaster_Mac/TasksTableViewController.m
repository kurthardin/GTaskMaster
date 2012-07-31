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

@synthesize taskListsController;
@synthesize tasklistsTableView;
@synthesize tasksTableView;

AppDelegate *_appDelegate;
NSWindow *_modalAddSheet;
NSString *_selectedTaskListId;

- (void)awakeFromNib {
    _appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
    
//    _taskListsController = [[NSArrayController alloc] initWithContent:nil];
//    [_taskListsController setManagedObjectContext:_appDelegate.taskManager.managedObjectContext];
//    [_taskListsController setEntityName:@"TaskList"];
//    [_taskListsController setAutomaticallyPreparesContent:YES];
//    NSError *error;
//    if ([_taskListsController fetchWithRequest:nil merge:YES error:&error]) {
//        [_taskListsController setSelectionIndex:0];
//    }
//    
//    _tasksController = [[NSArrayController alloc] initWithContent:nil];
//    [_tasksController setManagedObjectContext:_appDelegate.taskManager.managedObjectContext];
//    [_tasksController setEntityName:@"Task"];
//    [_tasksController setAutomaticallyPreparesContent:YES];
//    error = nil;
//    if ([_tasksController fetchWithRequest:nil merge:YES error:&error]) {
//        [_tasksController setSelectionIndex:0];
//    }
    
//    NSArray *tasklists = [_appDelegate.taskManager taskLists];
//    if (tasklists.count > 0) {
//        GTaskMasterManagedTaskList *taskList = [tasklists objectAtIndex:0];
//        _selectedTaskListId = taskList.identifier;
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableViews) name:@"tasks_updated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableViews)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:_appDelegate.taskManager.managedObjectContext];
}

- (void)refreshTableViews {
    [self.tasklistsTableView reloadData];
    [self.tasksTableView reloadData];
}

- (IBAction)addTaskList:(id)sender {
    [_appDelegate.taskListCreationPanelController show];
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

//-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
//    
//    if ([tableView isEqualTo:self.tasklistsTableView]) {
//        return YES;
//        
//    } else if ([tableView isEqualTo:self.tasksTableView]) {
//        if (_selectedTaskListId) {
//            GTaskMasterManagedTaskList *tasklist = [_appDelegate.taskManager taskListWithId:_selectedTaskListId];
//            NSOrderedSet *tasks = tasklist.tasks;
//            
//            if (row >= 0 && row < tasks.count) {
//                GTaskMasterManagedTask *task = [tasks objectAtIndex:row];
//                NSLog(@"selectedTask=%@", task);
//            }
//        }
//    }
//    
//    return NO;
//}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
//    NSInteger selectedRow = self.tasklistsTableView.selectedRow;
    
    if ([tableView isEqualTo:self.tasklistsTableView]) {
//        if (selectedRow < 0) {
//            _selectedTaskListId = nil;
//        } else {
//            NSArray *taskLists = [_appDelegate.taskManager taskLists];
//            if (selectedRow < taskLists.count) {
//                GTaskMasterManagedTaskList *taskList = [taskLists objectAtIndex:selectedRow];
//                NSLog(@"%@", taskList);
//                _selectedTaskListId = taskList.identifier;
//            }
//        }
        [self.tasksTableView reloadData];
    }
    
    
    
}

#pragma mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (self.taskListsController.selectedObjects.count > 0) {
        GTaskMasterManagedTaskList *tasklist = [self.taskListsController.selectedObjects objectAtIndex:0];
        NSOrderedSet *tasks = tasklist.tasks;
        return tasks.count;
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *title = @"FAIL";
    if (self.taskListsController.selectedObjects.count > 0) {
        GTaskMasterManagedTaskList *tasklist = [self.taskListsController.selectedObjects objectAtIndex:0];
        NSOrderedSet *tasks = tasklist.tasks;
        GTaskMasterManagedTask *task = [tasks objectAtIndex:rowIndex];
        title = [task createLabelString];
    }
    return title;
}

@end
