//
//  XNXcodeNav.h
//  XNXcodeNav
//
//  Created by Anh Khuc on 7/11/14.
//  Copyright (c) 2014 Anh Khuc. All rights reserved.
//

#import <AppKit/AppKit.h>

extern NSString * const XNDocumentChangedNotification;

@interface XNXcodeNav : NSObject

+ (instancetype)instance;

- (NSInteger)numberOfRecentDocuments;
- (NSString *)documentURLAtIndex:(NSInteger)index;
- (NSString *)documentNameAtIndex:(NSInteger)index;

@end