//
//  GTaskMasterLink.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 6/27/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

@class GTaskMasterManagedTask;

@interface GTaskMasterManagedLink : NSManagedObject

@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *type;

@property (nonatomic, retain) GTaskMasterManagedTask *task;

@end
