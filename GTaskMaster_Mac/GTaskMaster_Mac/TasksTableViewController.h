//
//  TasksTableViewController.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/16/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

@interface TasksTableViewController : NSObject <NSTableViewDelegate>

@property (nonatomic, readonly, strong) IBOutlet NSArrayController *taskListsController;
@property (nonatomic, readonly, strong) IBOutlet NSTableView *tasklistsTableView;
@property (nonatomic, readonly, strong) IBOutlet NSButton *addTaskListButton;

@property (nonatomic, readonly, strong) IBOutlet NSArrayController *tasksController;
@property (nonatomic, readonly, strong) IBOutlet NSTableView *tasksTableView;
@property (nonatomic, readonly, strong) IBOutlet NSButton *addTaskButton;

- (void)refreshTableViews;

@end
