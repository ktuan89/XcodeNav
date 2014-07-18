#import "XNApplicationHook.h"
#import "XNHooker.h"
#import "XNXcodeNav.h"

#import <AppKit/AppKit.h>

@interface NSApplication(Hook)
- (void)terminate__xn:(id)sender;
@end

@implementation XNApplicationHook

+ (void)hook
{
  [XNHooker hookClass:@"NSApplication" method:@"terminate:" byClass:[self class]];
}

// NSApplicationWillTerminateNotification somehow doesn't get called when I exit Xcode.
// Thus, this hook is needed to run code on exit
- (void)terminate:(id)sender
{
  [[XNXcodeNav instance] saveCurrentDocuments];
  [(NSApplication *)self terminate__xn:sender];
}

@end
