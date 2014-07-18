//
//  XNXcodeNav.h
//  XNXcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//  Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

extern NSString * const XNDocumentChangedNotification;

@class XNFileListView;

@interface XNXcodeNav : NSObject

+ (instancetype)instance;

- (NSInteger)numberOfRecentDocuments;
- (NSString *)documentURLAtIndex:(NSInteger)index;
- (NSString *)documentNameAtIndex:(NSInteger)index;
- (void)saveCurrentDocuments;
- (void)addSideBar:(XNFileListView *)sidebar;
- (void)removeSideBar:(XNFileListView *)sidebar;

@end