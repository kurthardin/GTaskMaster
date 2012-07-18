//
//  MySpotlightImporter.h
//  GTaskMaster_MacImporter
//
//  Created by Kurt Hardin on 6/21/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

@interface MySpotlightImporter : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)attributes error:(NSError **)error;

@end
