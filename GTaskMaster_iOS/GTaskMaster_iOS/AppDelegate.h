//
//  AppDelegate.h
//  GTaskMaster_iOS
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "LocalTaskManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) LocalTaskManager *taskManager;

- (NSURL *)applicationDocumentsDirectory;

@end
