//
//  Constants.m
//  LocationReminders
//
//  Created by mike davis on 9/3/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>

NSString *const ConstNotificationOfReminderAdded = @"ReminderAddedNotification";

NSString *const ConstReminderUserInfoTitleKey = @"reminderTitle";
NSString *const ConstReminderUserInfoPlaceKey = @"placeName";
NSString *const ConstReminderUserInfoCityKey = @"placeCity";
NSString *const ConstReminderUserInfoLatitudeKey = @"placeLatitude";
NSString *const ConstReminderUserInfoLongitudeKey = @"placeLongitude";

double const ConstReminderCloseRadiusMeters = 1000;
double const ConstReminderVeryCloseRadiusMeters = 100;
double const ConstReminderOverlayStrokeLineWidth = 0.8;
double const ConstReminderOverlayAlpha = 0.4;
