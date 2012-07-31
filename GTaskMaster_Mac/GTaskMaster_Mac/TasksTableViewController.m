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
@synthesize tasksController;
@synthesize tasksTableView;

AppDelegate *_appDelegate;
NSWindow *_modalAddSheet;
NSString *_selectedTaskListId;

- (void)awakeFromNib {
    _appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
    
    [self.taskListsController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NSOrderedAscending]]];
    [self.tasksController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:NSOrderedAscending]]];
    
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

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification.object isEqualTo:self.tasklistsTableView]) {
        if (self.taskListsController.selectedObjects.count > 0) {
            GTaskMasterManagedTaskList *tasklist = [self.taskListsController.selectedObjects objectAtIndex:0];
            
            [self.tasksController setFetchPredicate:[NSPredicate predicateWithFormat:@"tasklist.identifier == %@", tasklist.identifier]];
            [self.tasksController fetch:self];
            
            [self.tasksTableView reloadData];
        }
    }
}

@end
