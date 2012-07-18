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

@implementation AppDelegate

@synthesize window = _window;
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
        _taskManager = [[LocalTaskManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:_taskManager
                                                 selector:@selector(refresh:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[GTSyncManager sharedInstance].taskManager.managedObjectContext];
    }
    return _taskManager;
}

@end
