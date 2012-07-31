//
//  AppDelegate.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "LocalTaskManager.h"
#import "NewTaskPanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NewTaskPanelController *taskCreationPanelController;
@property (readonly, strong, nonatomic) LocalTaskManager *taskManager;

- (NSURL *)applicationFilesDirectory;

@end
