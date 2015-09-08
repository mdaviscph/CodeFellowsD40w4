//
//  AppDelegate.m
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "AppDelegate.h"
#import "Reminder.h"
#import "AlertPopover.h"
#import "Constants.h"
#import "Keys.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [Reminder registerSubclass];
  [Parse setApplicationId: (NSString *)ParseApplicationId clientKey: (NSString *)ParseClientId];
  
  if ([application respondsToSelector: @selector(registerUserNotificationSettings:)]) {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories: nil];
    [application registerUserNotificationSettings: settings];
  }
  return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  
  if (application.applicationState == UIApplicationStateActive && notification) {
    NSDictionary *userInfo = notification.userInfo;
    NSString *title = [userInfo objectForKey: ConstLocalNotificationTitleKey];
    NSString *place = [userInfo objectForKey: ConstLocalNotificationPlaceKey];
    NSNumber *distance = [userInfo objectForKey: ConstLocalNotificationDistanceKey];
    NSString *alertTitle = [[NSString alloc] initWithFormat: ConstReminderAlertTitleFormat, title];
    NSString *alertBody = [[NSString alloc] initWithFormat: @"You are approximately %0.2f kilometers from %@.", distance.doubleValue, place];
    UIViewController *rootVC = self.window.rootViewController;
    [AlertPopover alert: alertTitle withDescription: alertBody controller: rootVC completion: nil];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
