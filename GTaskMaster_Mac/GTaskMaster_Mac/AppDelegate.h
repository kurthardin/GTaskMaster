//
//  AppDelegate.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "LocalTaskManager.h"
#import "NewTaskPanelController.h"
#import "NewTaskListPanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, readonly, strong) NewTaskPanelController *taskCreationPanelController;
@property (nonatomic, readonly, strong) NewTaskListPanelController *taskListCreationPanelController;
@property (nonatomic, readonly, strong) LocalTaskManager *taskManager;

- (NSURL *)applicationFilesDirectory;

@end
