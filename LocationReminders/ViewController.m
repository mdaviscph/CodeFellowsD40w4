//
//  ViewController.m
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "ViewController.h"
#import "LocationService.h"
#import <MapKit/MapKit.h>
#import "CodingChallenges.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) LocationService *locationService;

@end

@implementation ViewController

- (LocationService *)locationService {
  if (!_locationService) {
    _locationService = [[LocationService alloc] init];
  }
  return _locationService;
}

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
  [super viewDidLoad];
  
  CodingChallenges *test = [[CodingChallenges alloc] init];
  [test monday];
  
  // SR520, 40th St.: 47.645997, -122.134871
  // SR520, I-405: 47.632241, -122.187911
  // SR520, Evergreen Pt.: 47.637193, -122.238407
  CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(47.645997, -122.134871);
  CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake(47.632241, -122.187911);
  CLLocationCoordinate2D center3 = CLLocationCoordinate2DMake(47.637193, -122.238407);
  
  MKCoordinateSpan span = MKCoordinateSpanMake(center1.latitude - center3.latitude, center1.longitude - center3.longitude);
  MKCoordinateRegion region = MKCoordinateRegionMake(center2, span);
  self.mapView.region = region;

  self.locationService.manager.delegate = self;
  BOOL authorized = [self.locationService requestAuthorization];
  if (authorized) {
    
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  BOOL available = [self.locationService isMonitoringAvailable:ServicesEnabled];
  if (available){
    self.mapView.showsUserLocation = YES;
  }
}

- (void)dealloc {
    // we don't currently need this because the mapView handles location updates
    // we will eventually stop region monitoring here if needed
    //[self.locationService.manager stopUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  switch (status) {
    case kCLAuthorizationStatusAuthorizedAlways:
        // not currently asking for this so we can ignore this case
      break;
    case kCLAuthorizationStatusDenied:
        //TODO: Alert popover
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        // we don't currently need this because the mapView handles location updates
        // we will eventually start region monitoring here
        //[self.locationService.manager startUpdatingLocation];
      break;
    case kCLAuthorizationStatusNotDetermined:
        // should not be changing back to this so we can ignore
      break;
    case kCLAuthorizationStatusRestricted:
        //TODO: Alert popover
      break;
    default:
      break;
  }
}

#pragma mark - MKMapViewDelegate

@end

