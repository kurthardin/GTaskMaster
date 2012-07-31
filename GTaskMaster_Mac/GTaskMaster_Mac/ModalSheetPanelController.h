//
//  ModalSheetPanelController.h
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/31/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalSheetController : NSObject

@property (nonatomic, readonly, strong) IBOutlet NSPanel *panel;

- (void)show;
- (void)showForWindow:(NSWindow *)window;

@end
