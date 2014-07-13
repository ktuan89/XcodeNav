//
//  XNXcodeNav.m
//  XNXcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//    Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import "XNXcodeNav.h"
#import "XNEditorHook.h"

NSString * const XNDocumentChangedNotification = @"XNDocumentChangedNotification";

static XNXcodeNav *sharedPlugin;

@interface XNXcodeNav() {
  NSMutableArray *_fileList;
}
@end

@implementation XNXcodeNav

+ (instancetype)instance
{
  static dispatch_once_t onceToken;
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    dispatch_once(&onceToken, ^{
      sharedPlugin = [[self alloc] init];
    });
  }
  return sharedPlugin;
}

+ (void)load
{
  NSBundle* app = [NSBundle mainBundle];
  NSString* identifier = [app bundleIdentifier];
  // Load only into Xcode
  if (![identifier isEqualToString:@"com.apple.dt.Xcode"]) {
    return;
  }

  [XNEditorHook hook];
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{

}

- (id)init
{
    if (self = [super init]) {
        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
      _fileList = [[NSMutableArray alloc] init];
    }
    return self;
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Hello, World" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"document"]) {
    NSString *documentPath = [[[object document] fileURL] path];
    if (documentPath != nil) {
      if (![documentPath isEqualToString:@""]) {
        [_fileList removeObject:documentPath];
        [_fileList insertObject:documentPath atIndex:0];
        if ([_fileList count] > 50) {
          [_fileList removeLastObject];
        }
      }
      [[NSNotificationCenter defaultCenter] postNotificationName:XNDocumentChangedNotification object:nil];
    }
  }
}

- (NSInteger)numberOfRecentDocuments
{
  return [_fileList count];
}

- (NSString *)documentURLAtIndex:(NSInteger)index
{
  return [_fileList objectAtIndex:index];
}

- (NSString *)documentNameAtIndex:(NSInteger)index
{
  NSString *docURL = [self documentURLAtIndex:index];
  NSRange range = [docURL rangeOfString:@"/" options:NSBackwardsSearch];
  if (range.location != NSNotFound) {
    NSString *docname = [docURL substringFromIndex:(range.location + 1)];
    return docname;
  }
  return @"";
}

@end
