//
//  ViewController.m
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "ViewController.h"
#import "AddReminderViewController.h"
#import "Constants.h"
#import "LocationService.h"
#import <MapKit/MapKit.h>
#import "CodingChallenges.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) LocationService *locationService;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;

- (void) startObservingNotifications;
- (void) stopObservingNotifications;
- (void) reminderAdded: (NSNotification *)notification;

@end

@implementation ViewController

NSString *segueToAddReminder = @"ShowAddReminder";
NSString *reusableAnnotationView = @"AnnotationView";

- (IBAction) longPressGesture:(UILongPressGestureRecognizer *)sender {
  CGPoint point = [sender locationInView:self.mapView];
  CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
  NSLog(@"point: (%0.2f, %0.2f)", point.x, point.y);
  NSLog(@"coordinate: (%0.4f, %0.4f)", coordinate.latitude, coordinate.longitude);
  
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  annotation.title = @"test";
  annotation.coordinate = coordinate;
  [self.mapView addAnnotation:annotation];
}

- (LocationService *)locationService {
  if (!_locationService) {
    _locationService = [[LocationService alloc] init];
  }
  return _locationService;
}

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
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
  [self startObservingNotifications];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  BOOL available = [self.locationService isMonitoringAvailable:ServicesEnabled];

  self.mapView.showsUserLocation = available ? YES : NO;
  self.mapView.delegate = available ? self : nil;
}

#pragma mark - Helper Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:segueToAddReminder]) {
    AddReminderViewController *detailVC = segue.destinationViewController;
    MKPointAnnotation *annotation = [[self.mapView selectedAnnotations] firstObject];
    if (annotation) {
      detailVC.annotation = annotation;
    }
  }
}

- (void) startObservingNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reminderAdded:) name:ConstNotificationOfReminderAdded object:nil];
}
- (void) stopObservingNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ConstNotificationOfReminderAdded object:nil];
}

- (void) reminderAdded: (NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  NSString *title = [userInfo objectForKey:ConstReminderUserInfoTitleKey];
  NSString *place = [userInfo objectForKey:ConstReminderUserInfoPlaceKey];
  NSString *city = [userInfo objectForKey:ConstReminderUserInfoCityKey];
  NSNumber *latitude = [userInfo objectForKey:ConstReminderUserInfoLatitudeKey];
  NSNumber *longitude = [userInfo objectForKey:ConstReminderUserInfoLongitudeKey];
  NSLog(@"reminder: %@ place: %@ city: %@ latitude: %.3f longitude: %.3f", title, place, city, latitude.doubleValue, longitude.doubleValue);
}
   
- (void) dealloc {
    // we don't currently need this because the mapView handles location updates
    // we will eventually stop region monitoring here if needed
    //[self.locationService.manager stopUpdatingLocation];
  [self stopObservingNotifications];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusableAnnotationView];
  if (pinView) {
    pinView.annotation = annotation;
  } else {
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusableAnnotationView];
  }
  pinView.pinColor = MKPinAnnotationColorGreen;
  pinView.canShowCallout = YES;
  
  UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  pinView.rightCalloutAccessoryView = rightButton;
  return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  MKPointAnnotation *pointAnnotation = (MKPointAnnotation *)view.annotation;
  if ([pointAnnotation.title isEqualToString:@"test"]) {
    NSLog(@"test annotation view selected");
  }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  MKPointAnnotation *pointAnnotation = (MKPointAnnotation *)view.annotation;
  if ([pointAnnotation.title isEqualToString:@"test"]) {
    NSLog(@"test annotation view selected with disclosure button");
  }
  [self performSegueWithIdentifier:segueToAddReminder sender:self];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  
}

@end

