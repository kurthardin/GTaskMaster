//
//  AppDelegate.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <GTL/GTMOAuth2WindowController.h>

#import "AppDelegate.h"
#import "GTSyncManager.h"

@interface AppDelegate ()

- (void)updateNotifications;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tasksViewController;
@synthesize taskCreationPanelController=_taskCreationPanelController;
@synthesize taskListCreationPanelController=_taskListCreationPanelController;
@synthesize taskManager = _taskManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    GTMOAuth2Authentication *auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:kKeychainItemName
                                                                                       clientID:kMyClientID
                                                                                   clientSecret:kMyClientSecret];
    
    if (!SAVE_AUTH_TOKEN) {
        [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
        [GTMOAuth2WindowController revokeTokenForGoogleAuthentication:auth];
    }
    
    if (auth.canAuthorize) {
        [[GTSyncManager sharedInstance].tasksService setAuthorizer:auth];
        [GTSyncManager startSyncing];
        
    } else {
        // Show the OAuth 2 sign-in controller
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[GTMOAuth2WindowController class]];
        GTMOAuth2WindowController *windowController;
        windowController = [GTMOAuth2WindowController controllerWithScope:kGTLAuthScopeTasks
                                                                 clientID:kMyClientID
                                                             clientSecret:kMyClientSecret
                                                         keychainItemName:(SAVE_AUTH_TOKEN ? kKeychainItemName : nil)
                                                           resourceBundle:frameworkBundle];
        
        [windowController signInSheetModalForWindow:self.window
                                  completionHandler:^(GTMOAuth2Authentication *auth,
                                                      NSError *error) {
                                      if (error) {
                                          NSLog(@"Error authenticating user:\n   %@", error);
                                      } else {
                                          [[GTSyncManager sharedInstance].tasksService setAuthorizer:auth];
                                          [GTSyncManager startSyncing];
                                      }
                                  }];
    }
    
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notificationCenter setDelegate:self];
    
    NSUserNotification *userNotification = [aNotification.userInfo objectForKey:NSApplicationLaunchUserNotificationKey];
    if (userNotification) {
        [self userNotificationCenter:notificationCenter didActivateNotification:userNotification];
    }
    
    [self updateNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotifications)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.taskManager.managedObjectContext];
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self.tasksViewController selectTask:[self.taskManager taskWithId:[notification.userInfo valueForKey:@"taskId"]]];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "kurthardin.GTaskMaster_Mac" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"kurthardin.GTaskMaster"];
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self.taskManager managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    NSManagedObjectContext *managedObjectContext = [self.taskManager managedObjectContext];
    if (!managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![managedObjectContext hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (LocalTaskManager *)taskManager {
    if (_taskManager == nil) {
        _taskManager = [[LocalTaskManager alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _taskManager;
}

- (NewTaskPanelController *)taskCreationPanelController {
    if (_taskCreationPanelController==nil) {
        _taskCreationPanelController = [[NewTaskPanelController alloc] init];
    }
    return _taskCreationPanelController;
}

- (NewTaskListPanelController *)taskListCreationPanelController {
    if (_taskListCreationPanelController==nil) {
        _taskListCreationPanelController = [[NewTaskListPanelController alloc] init];
    }
    return _taskListCreationPanelController;
}

- (void)updateNotifications {
    
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
//    [notificationCenter removeAllDeliveredNotifications];
//    for (NSUserNotification *notification in notificationCenter.scheduledNotifications) {
//        [notificationCenter removeScheduledNotification:notification];
//    }
//    NSLog(@"scheduledNotifications=%@", notificationCenter.scheduledNotifications);
//    NSLog(@"deliveredNotifications=%@", notificationCenter.deliveredNotifications);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.taskManager.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(status == %@) AND (due != nil) AND (gTDeleted == NO)", TASK_STATUS_INCOMPLETE]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"due" ascending:NSOrderedAscending]]];
    [fetchRequest setFetchLimit:25];
   
    NSError *err;
    NSArray *tasks = [self.taskManager.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    if (err) {
        NSLog(@"Error fetching tasks for notifications: %@", err);
    } else {
        
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDate *currentDate = [NSDate date];
        NSDateComponents* components = [calendar components:flags fromDate:currentDate];
        NSDate* currentDateOnly = [calendar dateFromComponents:components];
        
        for (GTaskMasterManagedTask *task in tasks) {
            
            components = [calendar components:flags fromDate:task.due];
            NSDate* dueDateOnly = [calendar dateFromComponents:components];
            
            BOOL notificationNeedsUpdate = NO;
            NSUserNotification *notification;
            
            if ([dueDateOnly compare:currentDateOnly] == NSOrderedDescending) {
                for (NSUserNotification *currentNotification in notificationCenter.scheduledNotifications) {
                    NSString *currentTaskId = [currentNotification.userInfo valueForKey:@"taskId"];
                    if ([currentTaskId isEqualToString:task.identifier]) {
                        notification = currentNotification;
                        break;
                    }
                }
                
            } else {
                for (NSUserNotification *currentNotification in notificationCenter.deliveredNotifications) {
                    NSString *currentTaskId = [currentNotification.userInfo valueForKey:@"taskId"];
                    if ([currentTaskId isEqualToString:task.identifier]) {
                        notification = currentNotification;
                        if ([notification.title hasSuffix:@"due."] && [dueDateOnly compare:currentDateOnly] == NSOrderedAscending) {
                            notificationNeedsUpdate = YES;
                        }
                        break;
                    }
                }
            }
            
            if (notification == nil) {
                notification = [[NSUserNotification alloc] init];
                notificationNeedsUpdate = YES;
            }
            
            if (notificationNeedsUpdate) {
                NSString *title = task.title;
                if ([dueDateOnly compare:currentDateOnly] == NSOrderedAscending) {
                    title = [title stringByAppendingString:@" is overdue!"];
                } else {
                    title = [title stringByAppendingString:@" is due."];
                }
                notification.title = title;
                notification.subtitle = task.tasklist.title;
                notification.hasActionButton = NO;
                notification.userInfo = [NSDictionary dictionaryWithObject:task.identifier forKey:@"taskId"];
                if ([dueDateOnly compare:currentDateOnly] == NSOrderedDescending) {
                    notification.deliveryDate = task.due;
                    [notificationCenter scheduleNotification:notification];
                } else {
                    [notificationCenter deliverNotification:notification];
                }
            }
        }
    }
}

@end
