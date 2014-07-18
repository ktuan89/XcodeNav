//
//  XNFileListView.h
//  XcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//  Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XNFileListView : NSView

@property (atomic, assign) CGFloat width;

- (void)layoutView:(NSView*)container;
- (void)didContainerFrameChanged:(NSNotification *)notification;

@end
