//
//  ModalSheetPanelController.m
//  GTaskMaster_Mac
//
//  Created by Kurt Hardin on 7/31/12.
//  Copyright (c) 2012 Kurt Hardin. All rights reserved.
//

#import "ModalSheetPanelController.h"
#import "AppDelegate.h"

@implementation ModalSheetController

@synthesize panel;

- (void)show {
    AppDelegate *appDelegate = (AppDelegate *) [NSApplication sharedApplication].delegate;
    [self showForWindow:appDelegate.window];
}

- (void)showForWindow:(NSWindow *)window {
    [NSApp beginSheet:self.panel
       modalForWindow:window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (void)dismiss {
    [NSApp endSheet:self.panel];
    [self.panel orderOut:nil];
}

@end
