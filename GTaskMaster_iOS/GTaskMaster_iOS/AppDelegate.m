//
//  AppDelegate.m
//  GTaskMaster_iOS
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "GTSyncManager.h"
#import "GTMOAuth2ViewControllerTouch.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize taskManager = _taskManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *mainNavigationController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.taskManager.managedObjectContext;
        controller.detailViewController = (DetailViewController *)[[splitViewController.viewControllers lastObject] topViewController];
        
        mainNavigationController = navigationController;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.taskManager.managedObjectContext;
        
        mainNavigationController = navigationController;
    }
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                          clientID:kMyClientID
                                                                                      clientSecret:kMyClientSecret];
    
    if (!SAVE_AUTH_TOKEN) {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    }
    
    if (auth.canAuthorize) {
        [[GTSyncManager sharedInstance].tasksService setAuthorizer:auth];
        [GTSyncManager startSyncing];
        
    } else {
        // Show the OAuth 2 sign-in controller
        GTMOAuth2ViewControllerTouch *authViewController;
        
        authViewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeTasks
                                                                      clientID:kMyClientID
                                                                  clientSecret:kMyClientSecret
                                                              keychainItemName:(SAVE_AUTH_TOKEN ? kKeychainItemName : nil)
                                                             completionHandler:^(GTMOAuth2ViewControllerTouch *viewController,
                                                                                 GTMOAuth2Authentication *auth,
                                                                                 NSError *error) {
                                                                 if (error) {
                                                                     NSLog(@"Error authenticating user:\n   %@", error);
                                                                 } else {
                                                                     [[GTSyncManager sharedInstance].tasksService setAuthorizer:auth];
                                                                     [GTSyncManager startSyncing];
                                                                 }
                                                             }];
        [mainNavigationController pushViewController:authViewController animated:YES];
        
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self.taskManager saveContext];
    [[GTSyncManager sharedInstance].taskManager saveContext];
}

- (LocalTaskManager *)taskManager {
    if (_taskManager == nil) {
        _taskManager = [[LocalTaskManager alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _taskManager;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
