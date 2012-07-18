//
//  TasksTableViewController.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/16/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

@interface TasksTableViewController : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet NSTableView *tasklistsTableView;
@property (nonatomic, strong) IBOutlet NSTableView *tasksTableView;

- (void)refreshTableViews;

@end
