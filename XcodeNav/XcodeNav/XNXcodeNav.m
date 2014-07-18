//
//  XNXcodeNav.m
//  XNXcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//    Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import "XNXcodeNav.h"
#import "XNEditorHook.h"
#import "XNApplicationHook.h"
#import "IDEKit.h"
#import "XNFileListView.h"

NSString * const XNDocumentChangedNotification = @"XNDocumentChangedNotification";

static XNXcodeNav *sharedPlugin;
static NSString * const kXNRecentFiles = @"recent_files";

@interface XNXcodeNav() {
  NSMutableArray *_fileList;
  NSMutableArray *_sideBars;
  CGFloat _sideBarWidth;
}
@property (atomic, strong) NSBundle *plugin;
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
  [XNApplicationHook hook];
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
  [XNXcodeNav instance].plugin = plugin;
  [[XNXcodeNav instance] reloadCurrentDocuments];
}

- (id)init
{
  if (self = [super init]) {
    // Putting this menu to Editor submenu doesn't work because Editor
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
    if (menuItem) {
      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
      NSMenuItem *containerMenuItem = [[NSMenuItem alloc] initWithTitle:@"Recent files" action:nil keyEquivalent:@""];
      [containerMenuItem setSubmenu:[[NSMenu alloc] init]];

      NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Toggle side bar" action:@selector(toggleSideBar) keyEquivalent:@"0"];
      [[containerMenuItem submenu] addItem:actionMenuItem];
      [actionMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
      [actionMenuItem setTarget:self];

      for (int i = 1; i <= 9; ++i) {
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Show recent %d", i] action:@selector(showRecent:) keyEquivalent:@""];
        [[containerMenuItem submenu] addItem:actionMenuItem];
        [actionMenuItem setKeyEquivalent:[NSString stringWithFormat:@"%d", i]];
        [actionMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
        [actionMenuItem setTarget:self];
        [actionMenuItem setRepresentedObject:@(i)];
      }
      [[menuItem submenu] addItem:containerMenuItem];
    }
    _fileList = [[NSMutableArray alloc] init];
    _sideBars = [[NSMutableArray alloc] init];
    _sideBarWidth = 200;
  }
  return self;
}

- (void)toggleSideBar
{
  if (_sideBarWidth > 100) _sideBarWidth = 0;
  else _sideBarWidth = 200;
  [_sideBars enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
    [(XNFileListView *)[obj nonretainedObjectValue] setWidth:_sideBarWidth];
  }];
}

// Sample Action, for menu item:
- (void)showRecent:(id)data
{
  NSInteger index = [(NSNumber *)[data representedObject] intValue];
  if (index >= [self numberOfRecentDocuments]) {
    return;
  }
  NSString *docPath = [self documentURLAtIndex:index];
  if(docPath != nil){
    IDEDocumentController* ctrl = [IDEDocumentController sharedDocumentController];
    NSError* error;
    NSURL* doc = [NSURL fileURLWithPath:docPath];
    [ctrl openDocumentWithContentsOfURL:doc display:YES error:&error];
  }
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
  if (index < 0 || index > [self numberOfRecentDocuments]) {
    return @"";
  }
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

- (void)addSideBar:(XNFileListView *)sidebar
{
  [_sideBars addObject:[NSValue valueWithNonretainedObject:sidebar]];
}

- (void)removeSideBar:(XNFileListView *)sidebar
{
  [_sideBars removeObject:[NSValue valueWithNonretainedObject:sidebar]];
}

- (NSString *)applicationSupportFolder
{
  NSString *bundleID = [[self plugin] bundleIdentifier];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSURL *dirPath = nil;

  // Find the application support directory in the home directory.
  NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                      inDomains:NSUserDomainMask];
  if ([appSupportDir count] > 0)
  {
    // Append the bundle ID to the URL for the
    // Application Support directory
    dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];

    // If the directory does not exist, this method creates it.
    // This method call works in OS X 10.7 and later only.
    NSError*    theError = nil;
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                       attributes:nil error:&theError])
    {
      // Handle the error.

      return nil;
    }
  }

  return [dirPath path];
}

- (NSString *)storageFilePath
{
  return [[[self applicationSupportFolder] stringByAppendingString:@"/"] stringByAppendingString:kXNRecentFiles];
}

- (void)saveCurrentDocuments
{
  NSString *filePath = [self storageFilePath];
  [NSKeyedArchiver archiveRootObject:_fileList toFile:filePath];
}

- (void)reloadCurrentDocuments
{
  NSString *filePath = [self storageFilePath];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    _fileList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  }
}

@end
