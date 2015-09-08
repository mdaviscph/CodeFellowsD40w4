//
//  AlertPopover.h
//  LocationReminders
//
//  Created by mike davis on 9/7/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;

extern NSString *const kErrorNotSignedIn;
extern NSString *const kErrorNoAccess;
extern NSString *const kErrorNoConnection;
extern NSString *const kErrorBadData;
extern NSString *const kErrorNoAuthorization;
extern NSString *const kErrorBusyOrServerError;
extern NSString *const kErrorNoNewData;
extern NSString *const kErrorLocationServicesDenied;
extern NSString *const kErrorLocationServicesRestricted;
extern NSString *const kEnableLocationServices;
extern NSString *const kErrorMapKit;
extern NSString *const kErrorParseFramework;

extern NSString *const kActionOk;

@interface AlertPopover : NSObject

+ (void) alert: (NSString *)title withNSError: (NSError *)error controller: (UIViewController *)parent completion: (void(^)(void)) handler;
+ (void) alert: (NSString *)title withStatusCode: (NSInteger)statusCode controller: (UIViewController *)parent completion: (void(^)(void)) handler;
+ (void) alert: (NSString *)title withDescription: (NSString *)message controller: (UIViewController *)parent completion: (void(^)(void)) handler;

@end
