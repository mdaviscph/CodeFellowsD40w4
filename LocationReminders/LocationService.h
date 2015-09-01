//
//  LocationService.h
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject

@property (strong, nonatomic) CLLocationManager *manager;

- (instancetype) init;
- (BOOL)requestAuthorization;
- (BOOL)isMonitoringAvailable;
@end
