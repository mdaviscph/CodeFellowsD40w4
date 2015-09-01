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
  //@import MapKit;

@interface ViewController ()
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // SR520, 40th St.: 47.645997, -122.134871
  // SR520, I-405: 47.632241, -122.187911
  // SR520, Evergreen Pt.: 47.637193, -122.238407
  CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(47.645997, -122.134871);
  CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake(47.632241, -122.187911);
  CLLocationCoordinate2D center3 = CLLocationCoordinate2DMake(47.637193, -122.238407);
  
  MKCoordinateSpan span = MKCoordinateSpanMake(center1.latitude - center3.latitude, center1.longitude - center3.longitude);
  MKCoordinateRegion region = MKCoordinateRegionMake(center2, span);
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center2, CLLocationDistance latitudinalMeters, <#CLLocationDistance longitudinalMeters#>)
  self.mapView.region = region;

  BOOL authorized = [self.locationService requestAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  BOOL available = [self.locationService isMonitoringAvailable];
  
  self.mapView.showsUserLocation = YES;
}

@end
