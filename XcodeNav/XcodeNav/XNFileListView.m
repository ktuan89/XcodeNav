//
//  XNFileListView.m
//  XcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//  Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import "XNFileListView.h"
#import "DVTKit.h"

@interface XNFileListView () {
  DVTChooserView* _background;
}

@end

@implementation XNFileListView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    /*Class class = NSClassFromString(@"DVTChooserView");
    _background = [[class alloc] init];
    _background.gradientStyle = 2;  // Style number 2 looks like IDEGlassBarView
    [_background setBorderSides:12]; // See DVTBorderedView.h for the meaning of the number*/

    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_documentChangedNotification:) name:XVimDocumentChangedNotification object:nil];

    // [self addSubview:_background];
    
  }
  return self;
}

- (void)didContainerFrameChanged:(NSNotification *)notification
{
  NSView* container = [notification object];
  [self layoutView:container];
}

- (void)layoutView:(NSView *)container
{
  NSRect parentRect = [container frame];
  CGFloat width = MIN(200, parentRect.size.width / 2);
  [self setFrame:NSMakeRect(parentRect.size.width - width, 0, width, parentRect.size.height)];
  // [_background setFrame:NSMakeRect(0, 0, width, parentRect.size.height)];
  if ([NSStringFromClass([container class]) isEqualToString:@"IDEComparisonEditorAutoLayoutView"]) {
    // Nothing ( Maybe AutoLayout view does the job "automatically")
  } else {
    if ([container subviews].count > 0) {
      [[[container subviews] objectAtIndex:0] setFrame:NSMakeRect(0, 0, parentRect.size.width - width, parentRect.size.height)];
    }
  }
}

@end
