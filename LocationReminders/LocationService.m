//
//  LocationService.m
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "LocationService.h"

@implementation LocationService

- (CLLocationManager *)manager {
  if (!_manager) {
    _manager = [[CLLocationManager alloc] init];
  }
  return _manager;
}

- (instancetype) init {
  self = [super init];
  if (self) {
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.activityType = CLActivityTypeFitness;
  }
  return self;
}

- (BOOL)requestAuthorization {
  BOOL authorized = NO;
  
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  switch (status) {
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      authorized = YES;
      break;
    case kCLAuthorizationStatusNotDetermined:
      [self.manager requestWhenInUseAuthorization];
      break;
    default:
      break;
  }
  return authorized;
}

- (BOOL)isMonitoringAvailable {
  BOOL available = NO;
  
  available = [CLLocationManager locationServicesEnabled];
  return available;
}
@end
