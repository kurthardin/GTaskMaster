//
//  MasterViewController.h
//  GTaskMaster_iOS
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
