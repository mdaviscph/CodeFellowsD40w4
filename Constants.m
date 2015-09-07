//
//  Constants.m
//  LocationReminders
//
//  Created by mike davis on 9/3/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "Constants.h"

// start - do not localize
NSString *const ConstNotificationOfReminderAdded = @"ReminderAddedNotification";
NSString *const ConstReminderUserInfoTitleKey = @"reminderTitle";
NSString *const ConstReminderUserInfoPlaceKey = @"placeName";
NSString *const ConstReminderUserInfoCityKey = @"placeCity";
NSString *const ConstReminderUserInfoLatitudeKey = @"placeLatitude";
NSString *const ConstReminderUserInfoLongitudeKey = @"placeLongitude";
NSString *const ConstLocalNotificationTitleKey = @"title";
NSString *const ConstLocalNotificationPlaceKey = @"place";
NSString *const ConstLocalNotificationDistanceKey = @"kilometers";
NSString *const ConstLocalNotificationDateKey = @"timestamp";
// end - do not localize

double const ConstReminderCloseRadiusMeters = 1500;
double const ConstReminderOverlayRadiusMeters = 250;
double const ConstReminderNotifyRadiusMeters = 500;
double const ConstReminderOverlayStrokeLineWidth = 0.8;
double const ConstReminderOverlayAlpha = 0.4;
double const ConstNewUserRegionMeters = 10000;
double const ConstLocalNotificationPeriodMinutes = 10;
double const ConstCoordinateAccuracy = 0.0001;          // approx. 11 meters

NSString *const ConstLoginButtonTitle = @"Login";
NSString *const ConstLogoutButtonTitle = @"Logout";
NSString *const ConstApplicationTitle = @"Location Reminders";
NSString *const ConstNewAnnotationTitle = @"Add a Reminder?";
NSString *const ConstInitialNavigationItemTitle = @"Home";
NSString *const ConstAddReminderNavigationItemTitle = @"Add Reminder";
NSString *const ConstReminderAlertTitleFormat = @"⏰ %@";
NSString *const ConstReminderAlertBodyFormat = @"You are approximately %0.2f kilometers from %@.";