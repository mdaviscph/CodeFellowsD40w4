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
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CodingChallenges.h"

#pragma mark -
@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
#pragma mark -

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) LocationService *locationService;
@property (strong, nonatomic) NSMutableArray *savedReminders;

- (void) startObservingNotifications;
- (void) stopObservingNotifications;
- (void) updateUI;
- (void) loginUser;
- (void) loginOutPressed;
- (void) reminderAdded: (NSNotification *)notification;
- (void) saveReminder: (Reminder *)reminder;
- (void) queryRemindersFor: (PFUser *)user;
- (void) addMapAnnotationsFor: (NSMutableArray *)reminders;
- (MKPointAnnotation *) annotationPoint: (CLLocationCoordinate2D)coordinate withTitle: (NSString *)title withSubtitle: (NSString *)subtitle;

@end

#pragma mark -
@implementation ViewController
#pragma mark -

NSString *const segueToAddReminder = @"ShowAddReminder";
NSString *const reusableAnnotationView = @"AnnotationView";
NSString *const loginButtonTitle = @"Login";
NSString *const logoutButtonTitle = @"Logout";
NSString *const newAnnotationTitle = @"Add a Reminder?";
NSString *const initialNavigationItemTitle = @"Home";

#pragma mark - IBActions

- (IBAction) longPressGesture:(UILongPressGestureRecognizer *)sender {
  CGPoint point = [sender locationInView:self.mapView];
  CLLocationCoordinate2D coordinate = [self.mapView convertPoint: point toCoordinateFromView: self.mapView];
  NSLog(@"point: (%0.2f, %0.2f)", point.x, point.y);
  NSLog(@"coordinate: (%0.4f, %0.4f)", coordinate.latitude, coordinate.longitude);
  
  [self.mapView addAnnotation: [self annotationPoint: coordinate withTitle: newAnnotationTitle withSubtitle: nil]];
}

#pragma mark - Private Property Getters, Setters

- (LocationService *)locationService {
  if (!_locationService) {
    _locationService = [[LocationService alloc] init];
  }
  return _locationService;
}

- (NSMutableArray *)savedReminders {
  if (!_savedReminders) {
    _savedReminders = [NSMutableArray array];
  }
  return _savedReminders;
}

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
  [super viewDidLoad];
  
  CodingChallenges *test = [[CodingChallenges alloc] init];
  [test monday];
  [test tuesday];
  [test wednesday];
  [test thursday];

  self.navigationItem.title = initialNavigationItemTitle;
  NSString *loginOutTitle = [PFUser currentUser] ? logoutButtonTitle : loginButtonTitle;
  UIBarButtonItem *loginOutButton = [[UIBarButtonItem alloc] initWithTitle: loginOutTitle style: UIBarButtonItemStylePlain target: self action:@selector(loginOutPressed)];
  self.navigationItem.rightBarButtonItem = loginOutButton;

  // SR520, 40th St.: 47.645997, -122.134871
  // SR520, I-405: 47.632241, -122.187911
  // SR520, Evergreen Pt.: 47.637193, -122.238407
//  CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(47.645997, -122.134871);
//  CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake(47.632241, -122.187911);
//  CLLocationCoordinate2D center3 = CLLocationCoordinate2DMake(47.637193, -122.238407);
//  
//  MKCoordinateSpan span = MKCoordinateSpanMake(center1.latitude - center3.latitude, center1.longitude - center3.longitude);
//  MKCoordinateRegion region = MKCoordinateRegionMake(center2, span);
//  self.mapView.region = region;

  self.locationService.manager.delegate = self;
  BOOL authorized = [self.locationService requestAuthorization];
  if (authorized) {
      // we don't currently need this because the mapView handles location updates
      // we will eventually start region monitoring here
      //[self.locationService.manager startUpdatingLocation];
  }
  
  if (![PFUser currentUser]) {
    [self loginUser];
  }
  [self updateMapAnnotations];

  [self startObservingNotifications];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  BOOL available = [self.locationService isMonitoringAvailable:ServicesEnabled];
  self.mapView.showsUserLocation = available ? YES : NO;
  self.mapView.delegate = available ? self : nil;
  
  // if returning from cancelled AddReminder VC remove one (or more if duplicates) related annotations
  for (MKPointAnnotation *annotation in [[self mapView] annotations]) {
    if ([annotation.title isEqualToString: newAnnotationTitle]) {
      [[self mapView] removeAnnotation: annotation];
    }
  }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender {
  if ([segue.identifier isEqualToString:segueToAddReminder]) {
    AddReminderViewController *detailVC = segue.destinationViewController;
    MKPointAnnotation *annotation = [[self.mapView selectedAnnotations] firstObject];
    if (annotation) {
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
  }
  [self updateMapAnnotations];
}

#pragma mark - Helper Methods

- (void) updateUI {
  if ([PFUser currentUser]) {
    self.navigationItem.rightBarButtonItem.title = logoutButtonTitle;
  }
  else {
    self.navigationItem.rightBarButtonItem.title = loginButtonTitle;
  }
  [self addMapAnnotationsFor: self.savedReminders];
}

- (void) updateMapAnnotations {
  if ([PFUser currentUser]) {
    [self queryRemindersFor: [PFUser currentUser]];
  }
  else {
    [self.mapView removeAnnotations: self.mapView.annotations];
    [self.savedReminders removeAllObjects];
  }
}

- (void) addMapAnnotationsFor: (NSMutableArray *)reminders {
  NSMutableArray *annotations = [NSMutableArray array];
  for (Reminder *reminder in reminders) {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(reminder.center.latitude, reminder.center.longitude);
    [annotations addObject: [self annotationPoint: coordinate withTitle: reminder.title withSubtitle: reminder.placeName]];
  }
    //[[self mapView] addAnnotations: annotations];
  [[self mapView] showAnnotations: annotations animated: YES];
}

- (MKPointAnnotation *) annotationPoint: (CLLocationCoordinate2D)coordinate withTitle: (NSString *)title withSubtitle: (NSString *)subtitle {
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  annotation.title = title;
  annotation.subtitle = subtitle;
  annotation.coordinate = coordinate;
  return annotation;
}

- (void) addMapOverlaysFor: (NSMutableArray *)reminders {
  NSMutableArray *annotations = [NSMutableArray array];
  for (Reminder *reminder in reminders) {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(reminder.center.latitude, reminder.center.longitude);
    [annotations addObject: [self annotationPoint: coordinate withTitle: reminder.title withSubtitle: reminder.placeName]];
  }
    //[[self mapView] addAnnotations: annotations];
  [[self mapView] showAnnotations: annotations animated: YES];
}

- (void) loginUser {
  PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
  [loginViewController setDelegate:self];
  [loginViewController setEmailAsUsername:YES];
  [loginViewController setTitle:@"Location Reminders"];
  
  PFSignUpViewController *signupViewController = [[PFSignUpViewController alloc] init];
  [signupViewController setDelegate:self];
  [signupViewController setEmailAsUsername:YES];
  [signupViewController setTitle:@"Location Reminders"];
  
  [loginViewController setSignUpController:signupViewController];
  [self presentViewController:loginViewController animated: YES completion: nil];
  [self updateMapAnnotations];
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
  NSLog(@"reminder: %@ place: %@ city: %@ latitude: %.3f longitude: %.3f", title, place, city, latitude.doubleValue, longitude.doubleValue);
  
  if (title && latitude && longitude) {
    Reminder *reminder = [[Reminder alloc] init];
    reminder.title = title;
    reminder.center = [PFGeoPoint geoPointWithLatitude: latitude.doubleValue longitude: longitude.doubleValue];
    reminder.placeName = place;
    reminder.placeCity = city;
    [self saveReminder: reminder];    // save new reminder or resave existing one, possibly with new title
    
    // change the Add a Reminder annotation to look the same as an annotation for a saved reminder
    // remove any extra annotations due to multiple long presses
    // force change in pin color by causing mapView:viewForAnnimation: to fire by removing and adding annotation
    BOOL addedOnce = NO;
    for (MKPointAnnotation *annotation in [[self mapView] annotations]) {
      if ([annotation.title isEqualToString: newAnnotationTitle]) {
        [[self mapView] removeAnnotation: annotation];
        if (!addedOnce) {
          addedOnce = YES;
          MKPointAnnotation* newAnnotation = [self annotationPoint: annotation.coordinate withTitle: reminder.title withSubtitle: reminder.placeName];
          [[self mapView] addAnnotation: newAnnotation];
          [[self mapView] selectAnnotation: newAnnotation animated: YES];
        }
      }
    }
  }
}

- (void) saveReminder:(Reminder *)reminder {
  if (![PFUser currentUser]) {
    [self loginUser];
  }
  if ([PFUser currentUser]) {
    reminder.user = [PFUser currentUser];
    [reminder saveInBackground];
  }
}

- (void) queryRemindersFor:(PFUser *)user {
  PFQuery *remindersQuery = [Reminder query];
  [remindersQuery whereKey: @"user" equalTo: [PFUser currentUser]];
  [remindersQuery findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
    for (id object in objects) {
      Reminder *reminder = (Reminder *)object;
      [self.savedReminders addObject: reminder];
    }
    [self updateUI]; // findObjectsInBackgroundWithBlock uses main queue for completion handler
  }];
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
  
  if ([annotation.title isEqualToString: newAnnotationTitle]) {
    pinView.pinColor = MKPinAnnotationColorGreen;
  } else {
    pinView.pinColor = MKPinAnnotationColorRed;
  }
  
  pinView.canShowCallout = YES;
  UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
  pinView.rightCalloutAccessoryView = rightButton;
  
  return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  MKPointAnnotation *pointAnnotation = (MKPointAnnotation *)view.annotation;
  if ([pointAnnotation.title isEqualToString: newAnnotationTitle]) {
    NSLog(@"new annotation view selected");
  }
}

- (void)mapView:(MKMapView *)mapView annotationView: (MKAnnotationView *)view calloutAccessoryControlTapped: (UIControl *)control {
  MKPointAnnotation *pointAnnotation = (MKPointAnnotation *)view.annotation;
  if ([pointAnnotation.title isEqualToString: newAnnotationTitle]) {
    NSLog(@"new annotation view selected with disclosure button");
  }
  [self performSegueWithIdentifier:segueToAddReminder sender: self];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation {
  
}

#pragma mark - PFSignUpViewControllerDelegate
- (void)signUpViewController: (PFSignUpViewController * __nonnull)signUpController didSignUpUser: (PFUser * __nonnull)user {
  [signUpController dismissViewControllerAnimated:YES completion: nil];
}

#pragma mark - PFLogInViewControllerDelegate
- (void)logInViewController: (PFLogInViewController * __nonnull)logInController didLogInUser: (PFUser * __nonnull)user {
  [logInController dismissViewControllerAnimated: YES completion: nil];
}

@end

