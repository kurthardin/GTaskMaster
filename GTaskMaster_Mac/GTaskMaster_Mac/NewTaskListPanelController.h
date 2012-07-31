//
//  NewTaskListPanelController.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/31/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "ModalSheetPanelController.h"

@interface NewTaskListPanelController : ModalSheetController

@property (nonatomic, readonly, strong) IBOutlet NSTextField *titleTextField;

@end
