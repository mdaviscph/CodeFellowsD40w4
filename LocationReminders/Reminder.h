//
//  Reminder.h
//  LocationReminders
//
//  Created by mike davis on 9/3/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Parse/Parse.h>

@interface Reminder: PFObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) PFGeoPoint *center;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *placeCity;
@property (strong, nonatomic) PFUser *user;

+ (NSString *) parseClassName;

@end
