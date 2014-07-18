//
//  XNFileListView.m
//  XcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//  Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import "XNFileListView.h"
#import "DVTKit.h"
#import "XNXcodeNav.h"

@interface XNTableView : NSTableView

@end

@implementation XNTableView

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
  [super resizeWithOldSuperviewSize:oldSize];
}

- (void)setFrame:(NSRect)frameRect
{
  NSLog(@"set frame: %@", @(frameRect.size.height));
  [super setFrame:frameRect];
}

- (void)setBounds:(NSRect)aRect
{
  [super setBounds:aRect];
}

@end

@interface XNFileListView () <NSTableViewDataSource, NSTableViewDelegate> {
  DVTChooserView* _background;
  NSTableView *_tableView;
  DVTFontAndColorTheme *_theme;
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


    // [self addSubview:_background];
    // self.wantsLayer = YES;
    // self.layer.backgroundColor = CGColorCreateGenericRGB(40.0/255, 43.0/255, 53.0/255, 1);
    _theme = [NSClassFromString(@"DVTFontAndColorTheme") performSelector:@selector(currentTheme)];
    _tableView = [[XNTableView alloc] initWithFrame:self.bounds];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"filename"];
    [_tableView addTableColumn:column];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addSubview:_tableView];
    [_tableView setBackgroundColor:[_theme sourceTextBackgroundColor]];
    // [self setAutoresizesSubviews:YES];
    // [_tableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_documentChangedNotification:) name:XNDocumentChangedNotification object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  // NSLog(@"layout view: %@", @(self.bounds.size.height));
  [_tableView setFrame:self.bounds];
  dispatch_async(dispatch_get_main_queue(), ^(){
    [_tableView setFrame:self.bounds];
  });
  // [_tableView resizeWithOldSuperviewSize:self.bounds.size];
  // [_background setFrame:NSMakeRect(0, 0, width, parentRect.size.height)];
  if ([NSStringFromClass([container class]) isEqualToString:@"IDEComparisonEditorAutoLayoutView"]) {
    // Nothing ( Maybe AutoLayout view does the job "automatically")
  } else {
    if ([container subviews].count > 0) {
      NSView *mainView = [[container subviews] objectAtIndex:0];
      NSRect mainRect = [mainView frame];
      mainRect.size.width = parentRect.size.width - width;
      [mainView setFrame:mainRect];
    }
  }
}

- (void)_documentChangedNotification:(NSNotification *)notification
{
  [_tableView reloadData];
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [[XNXcodeNav instance] numberOfRecentDocuments];
}

#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSTextField *result = [tableView makeViewWithIdentifier:@"FileList" owner:self];

  if (result == nil) {
    result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, 20)];
    result.identifier = @"FileList";
  }

  result.textColor = [_theme sourcePlainTextColor];
  result.font = [_theme sourcePlainTextFont];

  [result setEditable:NO];
  [result setSelectable:NO];
  [result setBordered:NO];
  [result setDrawsBackground:NO];
  [result setBezeled:NO];
  result.stringValue = [[XNXcodeNav instance] documentNameAtIndex:row];
  return result;
}

@end
