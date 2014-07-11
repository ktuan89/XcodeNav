
#import "XNEditorHook.h"
#import "Hooker.h"
#import "IDEKit.h"
#import "IDESourceEditor.h"
#import "XNFileListView.h"

@interface IDEEditor(Hook)
- (void)didSetupEditor_;
- (void)primitiveInvalidate_;
@end

@implementation XNEditorHook

static char _associatedViewKey = 0;

+ (void)hook
{
  [Hooker hookClass:@"IDEEditor" method:@"didSetupEditor" byClass:[self class]];
  [Hooker hookClass:@"IDEEditor" method:@"primitiveInvalidate" byClass:[self class]];
}

- (void)didSetupEditor
{
  IDEEditor* editor = (IDEEditor*)self;
  [editor didSetupEditor_];

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
			[container addSubview:fileListView];
      objc_setAssociatedObject(container, &_associatedViewKey, fileListView, OBJC_ASSOCIATION_RETAIN);

			// Layout
			[[NSNotificationCenter defaultCenter] addObserver:fileListView selector:@selector(didContainerFrameChanged:) name:NSViewFrameDidChangeNotification object:container];
			[fileListView layoutView:container];
			[container performSelector:@selector(invalidateLayout)];

      // For % register and to notify contents of editor is changed
      /*[editor addObserver:[XVim instance] forKeyPath:@"document" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
      objc_setAssociatedObject(editor, DID_REGISTER_OBSERVER_KEY, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);*/
		}
  }
  //---- TO HERE ----
}

- (void)primitiveInvalidate
{
  IDEEditor *editor = (IDEEditor *)self;
  [editor primitiveInvalidate_];
}

@end
