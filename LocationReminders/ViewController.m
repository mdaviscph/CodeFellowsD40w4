//
//  ViewController.m
//  LocationReminders
//
//  Created by mike davis on 8/31/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "ViewController.h"
#import "AddReminderViewController.h"
#import "Reminder.h"
#import "Constants.h"
#import "LocationService.h"
#import "AlertOnError.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CodingChallenges.h"

#pragma mark -
@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
#pragma mark -

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) LocationService *locationService;
@property (strong, nonatomic) NSArray *savedReminders;
@property CLLocationCoordinate2D selectedAnnotationCoordinate;
@property (strong, nonatomic) NSMutableDictionary *sentNotifications;
@property (strong, nonatomic) CLLocation* userLocation;

@end

#pragma mark -
@implementation ViewController
#pragma mark -

NSString *const userKey = @"user";
NSString *const segueToAddReminder = @"ShowAddReminder";
NSString *const reusableAnnotationView = @"AnnotationView";

UIColor *reminderCloseOverlayColor;
UIColor *reminderVeryCloseOverlayColor;
UIColor *reminderDefaultOverlayColor;
UIColor *reminderDefaultOverlayStrokeColor;

#pragma mark - IBActions

- (IBAction) longPressGesture:(UILongPressGestureRecognizer *)sender {
  CGPoint point = [sender locationInView:self.mapView];
  CLLocationCoordinate2D coordinate = [self.mapView convertPoint: point toCoordinateFromView: self.mapView];
  //NSLog(@"point: (%0.2f, %0.2f)", point.x, point.y);
  //NSLog(@"coordinate: (%0.5f, %0.5f)", coordinate.latitude, coordinate.longitude);
  [self.mapView addAnnotation: [self annotation: ConstNewAnnotationTitle fromCoordinate: coordinate withSubtitle: nil]];
}

#pragma mark - Private Property Getters, Setters

- (LocationService *)locationService {
  if (!_locationService) {
    _locationService = [[LocationService alloc] init];
  }
  return _locationService;
}

- (NSMutableDictionary *)sentNotifications {
  if (!_sentNotifications) {
    _sentNotifications = [[NSMutableDictionary alloc] init];
  }
  return _sentNotifications;
}

- (void) setUserLocation: (CLLocation*)userLocation {
  _userLocation = userLocation;
  if (!self.mapView.userLocationVisible || self.savedReminders.count == 0) {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, ConstNewUserRegionMeters, ConstNewUserRegionMeters);
    self.mapView.region = region;
  }
}

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
  [super viewDidLoad];
  
  CodingChallenges *test = [[CodingChallenges alloc] init];
  [test monday];
  [test tuesday];
  [test wednesday];
  [test thursday];

  self.navigationItem.title = ConstInitialNavigationItemTitle;
  NSString *loginOutTitle = [PFUser currentUser] ? ConstLogoutButtonTitle : ConstLoginButtonTitle;
  UIBarButtonItem *loginOutButton = [[UIBarButtonItem alloc] initWithTitle: loginOutTitle style: UIBarButtonItemStylePlain target: self action: @selector(loginOutPressed)];
  self.navigationItem.rightBarButtonItem = loginOutButton;
  UIBarButtonItem *pauseResumeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause target: self action: @selector(pauseResumePressed)];
  self.navigationItem.leftBarButtonItem = pauseResumeButton;
  
  reminderCloseOverlayColor = [UIColor blueColor];
  reminderVeryCloseOverlayColor = [UIColor redColor];
  reminderDefaultOverlayColor = [UIColor lightGrayColor];
  reminderDefaultOverlayStrokeColor = [UIColor darkGrayColor];
  
  self.locationService.manager.delegate = self;
  BOOL authorized = [self.locationService requestAuthorization];
  if (authorized) {
      // we don't currently need this because the mapView handles location updates
      // we will eventually start region monitoring here
      //[self.locationService.manager startUpdatingLocation];
  }
  
  if (![PFUser currentUser]) {
    [self loginUser];
  } else {
    [self updateMapBasedOnLogin];
  }

  self.selectedAnnotationCoordinate = CLLocationCoordinate2DMake(0, 0);
  [self startObservingNotifications];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  BOOL available = [self.locationService isMonitoringAvailable: ServicesEnabled];
  self.mapView.showsUserLocation = available ? YES : NO;
  self.mapView.delegate = available ? self : nil;
  
  // if returning from cancelled AddReminder VC remove one (or more if duplicates) related annotations
  for (MKPointAnnotation *annotation in [self.mapView annotations]) {
    if ([annotation.title isEqualToString: ConstNewAnnotationTitle]) {
      [self.mapView removeAnnotation: annotation];
    }
  }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender {
  if ([segue.identifier isEqualToString: segueToAddReminder]) {
    AddReminderViewController *detailVC = segue.destinationViewController;
    MKPointAnnotation *annotation = [[self.mapView selectedAnnotations] firstObject];
    if (annotation) {
      self.selectedAnnotationCoordinate = annotation.coordinate;
      detailVC.annotation = annotation;
    }
  }
}

#pragma mark - Button Selector Methods

- (void) loginOutPressed {
  if (![PFUser currentUser]) {
    [self loginUser];
  } else {
    [PFUser logOut];
    [self updateMapBasedOnLogin];
  }
}

- (void) pauseResumePressed {
  UIBarButtonItem *pauseResumeButton;
  if (self.mapView.showsUserLocation) {
    pauseResumeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPlay target: self action: @selector(pauseResumePressed)];
  } else {
    pauseResumeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause target: self action: @selector(pauseResumePressed)];
  }
  self.navigationItem.leftBarButtonItem = pauseResumeButton;
  self.mapView.showsUserLocation = !self.mapView.showsUserLocation;
}

#pragma mark - Helper Methods

- (void) updateUI {
  if ([PFUser currentUser]) {
    self.navigationItem.rightBarButtonItem.title = ConstLogoutButtonTitle;
  }
  else {
    self.navigationItem.rightBarButtonItem.title = ConstLoginButtonTitle;
  }
  [self addMapAnnotationsFor: self.savedReminders];
  [self addMapOverlaysFor: self.savedReminders];
}

- (void) updateMapBasedOnLogin {
  if ([PFUser currentUser]) {
    [self queryRemindersFor: [PFUser currentUser]];
  }
  else {
    [self.mapView removeAnnotations: self.mapView.annotations];
    [self.mapView removeOverlays: self.mapView.overlays];
    self.savedReminders =nil;
    [self updateUI];
  }
}

- (void) addMapAnnotationsFor: (NSArray *)reminders {
  MKPointAnnotation *selectedAnnotation;
  NSMutableArray *annotations = [[NSMutableArray alloc] init];
  for (Reminder *reminder in reminders) {
    MKPointAnnotation *annotation = [self annotation: reminder.title fromGeoPoint: reminder.center withSubtitle: reminder.placeName];
    [annotations addObject: annotation];
    if ([self isGeoPoint: reminder.center equalTo: self.selectedAnnotationCoordinate]) {
      selectedAnnotation = annotation;
    }
  }
  [self.mapView addAnnotations: annotations];
  if (selectedAnnotation) {
    self.selectedAnnotationCoordinate = CLLocationCoordinate2DMake(0, 0);
    [self.mapView selectAnnotation: selectedAnnotation animated: YES];
  }
  //[self.mapView showAnnotations: annotations animated: YES];
}

- (MKPointAnnotation *) annotation: (NSString *)title fromCoordinate: (CLLocationCoordinate2D)coordinate withSubtitle: (NSString *)subtitle {
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  annotation.title = title;
  annotation.subtitle = subtitle;
  annotation.coordinate = coordinate;
  return annotation;
}

- (MKPointAnnotation *) annotation: (NSString *)title fromGeoPoint: (PFGeoPoint *)geoPoint withSubtitle: (NSString *)subtitle {
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  annotation.title = title;
  annotation.subtitle = subtitle;
  annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
  return annotation;
}

- (void) addMapOverlaysFor: (NSArray *)reminders {
  NSMutableArray *overlays = [[NSMutableArray alloc] init];
  for (Reminder *reminder in reminders) {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(reminder.center.latitude, reminder.center.longitude);
    [overlays addObject: [self overlayCircle: coordinate]];
  }
  [self.mapView addOverlays: overlays];
}

- (MKCircle *) overlayCircle: (CLLocationCoordinate2D)coordinate {
  MKCircle *overlay = [MKCircle circleWithCenterCoordinate: coordinate radius: ConstReminderOverlayRadiusMeters];
  return overlay;
}

- (void) loginUser {
  PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
  [loginViewController setDelegate:self];
  [loginViewController setEmailAsUsername:YES];
  [loginViewController setTitle: ConstApplicationTitle];
  
  PFSignUpViewController *signupViewController = [[PFSignUpViewController alloc] init];
  [signupViewController setDelegate:self];
  [signupViewController setEmailAsUsername:YES];
  [signupViewController setTitle: ConstApplicationTitle];
  
  [loginViewController setSignUpController:signupViewController];
  [self presentViewController:loginViewController animated: YES completion: nil];
}

- (void) startObservingNotifications {
  [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reminderAdded:) name: ConstNotificationOfReminderAdded object: nil];
}
- (void) stopObservingNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver: self name:ConstNotificationOfReminderAdded object: nil];
}

- (void) reminderAdded: (NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  NSString *title = [userInfo objectForKey: ConstReminderUserInfoTitleKey];
  NSString *place = [userInfo objectForKey: ConstReminderUserInfoPlaceKey];
  NSString *city = [userInfo objectForKey: ConstReminderUserInfoCityKey];
  NSNumber *latitude = [userInfo objectForKey: ConstReminderUserInfoLatitudeKey];
  NSNumber *longitude = [userInfo objectForKey: ConstReminderUserInfoLongitudeKey];
  //NSLog(@"reminder: %@ place: %@ city: %@ latitude: %.5f longitude: %.5f", title, place, city, latitude.doubleValue, longitude.doubleValue);
  
  if (title && title.length > 0 && latitude && longitude) {
    Reminder *reminder = [[Reminder alloc] init];
    reminder.title = title;
    reminder.center = [PFGeoPoint geoPointWithLatitude: latitude.doubleValue longitude: longitude.doubleValue];
    reminder.placeName = place;
    reminder.placeCity = city;
    
    CLLocationCoordinate2D newReminderCoordinate = CLLocationCoordinate2DMake(reminder.center.latitude, reminder.center.longitude);
    for (Reminder *oldReminder in self.savedReminders) {
      CLLocationCoordinate2D oldReminderCoordinate = CLLocationCoordinate2DMake(oldReminder.center.latitude, oldReminder.center.longitude);
      if ([self isCoordinate: oldReminderCoordinate equalTo: newReminderCoordinate]) {
        [oldReminder deleteInBackground];
      }
    }
    [self saveReminder: reminder];
  }
}

- (void) saveReminder:(Reminder *)reminder {
  if ([PFUser currentUser]) {
    reminder.user = [PFUser currentUser];
    [reminder saveInBackground];
    // savedReminders is only mutated by results from query (actually replaced)
    [self queryRemindersFor: [PFUser currentUser]];
  }
}

- (void) queryRemindersFor: (PFUser *)user {
  NSMutableArray* reminders = [[NSMutableArray alloc] init];
  PFQuery *remindersQuery = [Reminder query];
  [remindersQuery whereKey: userKey equalTo: [PFUser currentUser]];
  [remindersQuery findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
    for (id object in objects) {
      Reminder *reminder = (Reminder *)object;
      [reminders addObject: reminder];
    }
    // TODO: handle error
    self.savedReminders = reminders;
    [self updateUI];        // findObjectsInBackgroundWithBlock uses main queue for completion handler
  }];
}

- (void) trackLocalNotificationFor: (Reminder *)reminder withDistanceInKilometers: (double)kilometers {
  NSDate *sent = [self.sentNotifications objectForKey: reminder.title];
  NSDate* now = [[NSDate alloc] init];
  if (sent) {
    if ([now timeIntervalSinceDate: sent] > ConstLocalNotificationPeriodMinutes * 60) {
      [self.sentNotifications setObject: now forKey: reminder.title];
      [self sendLocalNotificationFor: reminder withDistanceInKilometers: kilometers at: now];
    }
  } else {
    [self.sentNotifications setObject: now forKey: reminder.title];
    [self sendLocalNotificationFor: reminder withDistanceInKilometers: kilometers at: now];
  }
}

- (void) sendLocalNotificationFor: (Reminder *)reminder withDistanceInKilometers: (double)kilometers at: (NSDate *)timestamp {
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  NSString *alertTitle = [[NSString alloc] initWithFormat: ConstReminderAlertTitleFormat, reminder.title];
  NSString *alertBody = [[NSString alloc] initWithFormat: @"You are approximately %0.2f kilometers from %@.", kilometers, reminder.placeName];
  notification.alertTitle = alertTitle;
  notification.alertBody = alertBody;
  notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: reminder.title, ConstLocalNotificationTitleKey, reminder.placeName, ConstLocalNotificationPlaceKey, @(kilometers), ConstLocalNotificationDistanceKey, timestamp, ConstLocalNotificationDateKey, nil];
  [[UIApplication sharedApplication] presentLocalNotificationNow: notification];
  NSLog(@"local notification for reminder: %@ distance: %0.3f timestamp: %@", reminder.title, kilometers, timestamp);
}

- (BOOL) isCoordinate: (CLLocationCoordinate2D)coordinate1 equalTo: (CLLocationCoordinate2D)coordinate2 {
  return fabs(coordinate1.latitude - coordinate2.latitude) < ConstCoordinateAccuracy && fabs(coordinate1.longitude - coordinate2.longitude) < ConstCoordinateAccuracy;
}

- (BOOL) isGeoPoint: (PFGeoPoint *)geoPoint equalTo: (CLLocationCoordinate2D)coordinate {
  return fabs(geoPoint.latitude - coordinate.latitude) < ConstCoordinateAccuracy && fabs(geoPoint.longitude - coordinate.longitude) < ConstCoordinateAccuracy;
}

#pragma mark -
- (void) dealloc {
    // we don't currently need this because the mapView handles location updates
    // we will eventually stop region monitoring here if needed
    //[self.locationService.manager stopUpdatingLocation];
  [PFUser logOutInBackground];
  [self stopObservingNotifications];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager: (CLLocationManager *)manager didChangeAuthorizationStatus: (CLAuthorizationStatus)status {
  switch (status) {
    case kCLAuthorizationStatusAuthorizedAlways:
        // not currently asking for this so we can ignore this case
      break;
    case kCLAuthorizationStatusDenied:
      [AlertOnError alertPopover: kErrorLocationServicesDenied withDescription: kEnableLocationServices controller: self completion: nil];
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      if ([self.locationService isMonitoringAvailable: ServicesEnabled]) {
        self.mapView.showsUserLocation = YES;
        self.mapView.delegate = self;
        // we don't currently need this because the mapView handles location updates
        // we will eventually start region monitoring here
        //[self.locationService.manager startUpdatingLocation];
      }
      break;
    case kCLAuthorizationStatusNotDetermined:
        // should not be changing back to this so we can ignore
      break;
    case kCLAuthorizationStatusRestricted:
      [AlertOnError alertPopover: kErrorLocationServicesDenied withDescription: kEnableLocationServices controller: self completion: nil];
      break;
  }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation: (id<MKAnnotation>)annotation {
  
  if ([annotation isKindOfClass: [MKUserLocation class]]) {
    return nil;
  }
  MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier: reusableAnnotationView];
  if (pinView) {
    pinView.annotation = annotation;
  } else {
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: reusableAnnotationView];
  }
  
  if ([annotation.title isEqualToString: ConstNewAnnotationTitle]) {
    pinView.pinColor = MKPinAnnotationColorGreen;
  } else {
    pinView.pinColor = MKPinAnnotationColorRed;
  }
  
  pinView.canShowCallout = YES;
  UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
  pinView.rightCalloutAccessoryView = rightButton;
  
  return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView: (MKAnnotationView *)view calloutAccessoryControlTapped: (UIControl *)control {

  [self performSegueWithIdentifier: segueToAddReminder sender: self];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay: overlay];
  
  CLLocationDistance distance = CLLocationDistanceMax;
  CLLocation *circleLocation = [[CLLocation alloc] initWithLatitude: overlay.coordinate.latitude longitude: overlay.coordinate.longitude];
  if (self.userLocation) {
    distance = [circleLocation distanceFromLocation: self.userLocation];
  }
  //NSLog(@"pin: %.5f %.5f user: %.5f %.5f distance %.1f", [overlay coordinate].latitude, [overlay coordinate].longitude, self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude, distance == CLLocationDistanceMax ? -1.0 : distance);
  if (distance < ConstReminderOverlayRadiusMeters) {
    renderer.fillColor = reminderVeryCloseOverlayColor;
  } else if (distance < ConstReminderCloseRadiusMeters){
    renderer.fillColor = reminderCloseOverlayColor;
  } else {
    renderer.fillColor = [UIColor lightGrayColor];
  }
  
  renderer.lineWidth = ConstReminderOverlayStrokeLineWidth;
  renderer.strokeColor = [UIColor darkGrayColor];
  renderer.alpha = ConstReminderOverlayAlpha;
  return renderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation {
  if (userLocation.location) {
    self.userLocation = userLocation.location;
    PFGeoPoint* userGeoPoint = [PFGeoPoint geoPointWithLatitude: userLocation.location.coordinate.latitude longitude: userLocation.location.coordinate.longitude];
    for (Reminder *reminder in self.savedReminders) {
      double distanceKilometers = [userGeoPoint distanceInKilometersTo:reminder.center];
      double distanceMeters = distanceKilometers * 1000;
      if (distanceMeters < ConstReminderCloseRadiusMeters) {
//        CLLocationCoordinate2D reminderCoordinate = CLLocationCoordinate2DMake(reminder.center.latitude, reminder.center.longitude);
//        for (MKCircle *overlay in self.mapView.overlays) {
//          if ([self isCoordinate: overlay.coordinate equalTo: reminderCoordinate]) {
//            [self.mapView removeOverlay: overlay];
//            MKCircle *overlay = [self overlayCircle: reminderCoordinate];
//            [self.mapView addOverlay: overlay];
//            break;
//          }
//        }
        // TODO: a better method for changing overlay back to other colors; with the method of removing
        // and adding overlays we don't currently need to remove and add single overlay for this reminder
        NSArray *overlays = [self.mapView overlays];
        [self.mapView removeOverlays: overlays];
        [self.mapView addOverlays: overlays];
      }
      if (distanceMeters < ConstReminderNotifyRadiusMeters) {
        [self trackLocalNotificationFor: reminder withDistanceInKilometers: distanceKilometers];
      }
    }
  }
}

#pragma mark - PFSignUpViewControllerDelegate
- (void)signUpViewController: (PFSignUpViewController * __nonnull)signUpController didSignUpUser: (PFUser * __nonnull)user {
  
  [signUpController dismissViewControllerAnimated:YES completion: nil];
}

#pragma mark - PFLogInViewControllerDelegate
- (void)logInViewController: (PFLogInViewController * __nonnull)logInController didLogInUser: (PFUser * __nonnull)user {
  
  [self updateMapBasedOnLogin];
  [logInController dismissViewControllerAnimated: YES completion: nil];
}

@end

