//
//  AlertPopover.m
//  LocationReminders
//
//  Created by mike davis on 9/7/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "AlertPopover.h"
#import <UIKit/UIKit.h>

NSString *const kErrorNotSignedIn = @"Please sign in and try again.";
NSString *const kErrorNoAccess = @"Please grant access to your account to continue.";
NSString *const kErrorNoConnection = @"Cannot connect to server. Please try again later.";
NSString *const kErrorBadData = @"Unable to communicate successfully with server. Please try again later.";
NSString *const kErrorNoAuthorization = @"Access denied by server. Please verify your account.";
NSString *const kErrorBusyOrServerError = @"Service is unavailable. Please try again later.";
NSString *const kErrorNoNewData = @"No new data. Please try again later.";
NSString *const kErrorLocationServicesDenied = @"Location Services - Authorization Denied.";
NSString *const kErrorLocationServicesRestricted = @"Location Services - Authorization Restricted.";
NSString *const kEnableLocationServices = @"Please enable Location Services - Allow Access: [While Using the App]";
NSString *const kErrorMapKit = @"Mapping Service";
NSString *const kErrorParseFramework = @"Parse Framework Error";

NSString *const kActionOk = @"Ok";

@interface AlertPopover ()
@end

@implementation AlertPopover

NSString *const kStatusCodeErrorFormat = @"%@ (%ld)";

+ (void) alert: (NSString *)title withNSError: (NSError *)error controller: (UIViewController *)parent completion: (void(^)(void)) handler {
  NSString *message = error.localizedDescription;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message: message preferredStyle: UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = parent.view;
  alert.popoverPresentationController.sourceRect = parent.view.frame;
  UIAlertAction *okAction = [UIAlertAction actionWithTitle: kActionOk style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    if (handler) {
      handler();
    }
  }];
  [alert addAction: okAction];
  [parent presentViewController: alert animated: YES completion: nil];
}

+ (void) alert: (NSString *)title withStatusCode: (NSInteger)statusCode controller: (UIViewController *)parent completion: (void(^)(void)) handler {
  NSString *message;
  if (statusCode >= 200 && statusCode < 300) {
    message = [NSString stringWithFormat: kStatusCodeErrorFormat, kErrorBadData, (long)statusCode];
  } else if (statusCode >= 300 && statusCode < 400) {
    message = [NSString stringWithFormat: kStatusCodeErrorFormat, kErrorNoNewData, (long)statusCode];
  } else if (statusCode >= 400 && statusCode < 500) {
    message = [NSString stringWithFormat: kStatusCodeErrorFormat, kErrorNoAuthorization, (long)statusCode];
  } else if (statusCode >= 500 && statusCode < 600) {
    message = [NSString stringWithFormat: kStatusCodeErrorFormat, kErrorBusyOrServerError, (long)statusCode];
  } else {
    message = [NSString stringWithFormat: kStatusCodeErrorFormat, kErrorBusyOrServerError, (long)statusCode];
  }

  UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message: message preferredStyle: UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = parent.view;
  alert.popoverPresentationController.sourceRect = parent.view.frame;
  UIAlertAction *okAction = [UIAlertAction actionWithTitle: kActionOk style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    if (handler) {
      handler();
    }
  }];
  [alert addAction: okAction];
  [parent presentViewController: alert animated: YES completion: nil];
}

+ (void) alert: (NSString *)title withDescription: (NSString *)message controller: (UIViewController *)parent completion: (void(^)(void)) handler {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message: message preferredStyle: UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = parent.view;
  alert.popoverPresentationController.sourceRect = parent.view.frame;
  UIAlertAction *okAction = [UIAlertAction actionWithTitle: kActionOk style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    if (handler) {
      handler();
    }
  }];
  [alert addAction: okAction];
  [parent presentViewController: alert animated: YES completion: nil];
}

@end
