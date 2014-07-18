
#import "XNEditorHook.h"
#import "XNHooker.h"
#import "IDEKit.h"
#import "IDESourceEditor.h"
#import "XNFileListView.h"
#import "XNXcodeNav.h"

#define DID_REGISTER_OBSERVER_KEY   "XcodeNav.IDEEditorHook._didRegisterObserver"

@interface IDEEditor(Hook)
- (void)didSetupEditor__xn;
- (void)primitiveInvalidate__xn;
@end

@implementation XNEditorHook

static char _associatedViewKey = 0;

+ (void)hook
{
  [XNHooker hookClass:@"IDEEditor" method:@"didSetupEditor" byClass:[self class]];
  [XNHooker hookClass:@"IDEEditor" method:@"primitiveInvalidate" byClass:[self class]];
}

- (void)didSetupEditor
{
  IDEEditor* editor = (IDEEditor*)self;
  [editor didSetupEditor__xn];

  NSView* container = nil;
  if ([NSStringFromClass([editor class]) isEqualToString:@"IDESourceCodeComparisonEditor"]) {
    container = [(IDESourceCodeComparisonEditor*)editor layoutView];
  } else if ([NSStringFromClass([editor class]) isEqualToString:@"IDESourceCodeEditor"]) {
    container = [(IDESourceCodeEditor*)editor containerView];
  } else {
    return;
  }

  if (container != nil) {
    XNFileListView *fileListView = objc_getAssociatedObject(container, &_associatedViewKey);
    if (fileListView == nil) {
      // Insert status line
      [container setPostsFrameChangedNotifications:YES];
      fileListView = [[XNFileListView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
      [fileListView setWidth:200];
      // NSView *fileListContainer = [[NSView alloc] init];
      // fileListContainer addSubview:
      [container addSubview:fileListView];
      objc_setAssociatedObject(container, &_associatedViewKey, fileListView, OBJC_ASSOCIATION_RETAIN);

      // Layout
      [[NSNotificationCenter defaultCenter] addObserver:fileListView selector:@selector(didContainerFrameChanged:) name:NSViewFrameDidChangeNotification object:container];
      [fileListView layoutView:container];
      [container performSelector:@selector(invalidateLayout)];

      // For % register and to notify contents of editor is changed
      [editor addObserver:[XNXcodeNav instance] forKeyPath:@"document" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
      objc_setAssociatedObject(editor, DID_REGISTER_OBSERVER_KEY, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
    }
  }
  //---- TO HERE ----
}

- (void)primitiveInvalidate
{
  IDEEditor *editor = (IDEEditor *)self;
  NSNumber *didRegisterObserver = objc_getAssociatedObject(editor, DID_REGISTER_OBSERVER_KEY);
  if ([didRegisterObserver boolValue]) {
    [editor removeObserver:[XNXcodeNav instance] forKeyPath:@"document"];
  }
  [editor primitiveInvalidate__xn];
}

@end
