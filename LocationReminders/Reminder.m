//
//  Reminder.m
//  LocationReminders
//
//  Created by mike davis on 9/3/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "Reminder.h"

@interface Reminder() <PFSubclassing>

@end
@implementation Reminder

@dynamic title;
@dynamic center;
@dynamic placeName;
@dynamic placeCity;
@dynamic user;

+ (NSString *) parseClassName {
  return @"Reminder";
}

@end
