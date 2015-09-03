//
//  AddReminderViewController.m
//  LocationReminders
//
//  Created by mike davis on 9/2/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

@interface AddReminderViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) MKPlacemark *placemark;
@property (strong, nonatomic) NSString *city;

- (void) donePressed;
- (void) cancelPressed;

@end

@implementation AddReminderViewController

@synthesize annotation = _annotation;
- (MKPointAnnotation *) annotation {
  return _annotation;
}
- (void) setAnnotation:(MKPointAnnotation *)annotation {
  _annotation = annotation;
  if (annotation.title) {
    self.titleTextField.text = annotation.title;
  }
}
@synthesize placemark = _placemark;
- (MKPlacemark *) placemark {
  return _placemark;
}
- (void) setPlacemark:(MKPlacemark *)placemark {
  _placemark = placemark;
  self.addressLabel.text = placemark.name;
  self.city = [placemark.addressDictionary objectForKey:@"City"];
  self.cityLabel.text = self.city;

//  for (id key in placemark.addressDictionary) {
//    id value = placemark.addressDictionary[key];
//    NSLog(@"address dictionary: key: %@, value %@", key, value);
//  }
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = @"Add Reminder";
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
  self.navigationItem.rightBarButtonItem = doneButton;
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];
  self.navigationItem.leftBarButtonItem = cancelButton;

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  CLLocation *location = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
  
  [geocoder reverseGeocodeLocation:location completionHandler: ^(NSArray* placemarks, NSError* error){
     if ([placemarks count] > 0) {
       self.placemark = [placemarks objectAtIndex:0];
     }
   }];
}

#pragma mark - Button Selector Methods

- (void) donePressed {
  if (self.titleTextField.text) {
    self.annotation.title = self.titleTextField.text;
  }
  NSMutableArray *values = [[NSMutableArray alloc] init];
  NSMutableArray *keys = [[NSMutableArray alloc] init];
  if (self.annotation.title) {
    [values addObject:self.annotation.title];
    [keys addObject:ConstReminderUserInfoTitleKey];
  }
  if (self.placemark.name) {
    [values addObject:self.placemark.name];
    [keys addObject:ConstReminderUserInfoPlaceKey];
  }
  if (self.city) {
    [values addObject:self.city];
    [keys addObject:ConstReminderUserInfoCityKey];
  }
  NSNumber* latitude = [[NSNumber alloc] initWithDouble:self.annotation.coordinate.latitude];
  NSNumber* longitude = [[NSNumber alloc] initWithDouble:self.annotation.coordinate.longitude];

  [values addObject:latitude];
  [keys addObject:ConstReminderUserInfoLatitudeKey];
  [values addObject:longitude];
  [keys addObject:ConstReminderUserInfoLongitudeKey];
  
  NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  [[NSNotificationCenter defaultCenter] postNotificationName:ConstNotificationOfReminderAdded object:self userInfo:userInfo];
  [self.navigationController popViewControllerAnimated:YES];
  return;
}

- (void) cancelPressed {
  [self.navigationController popViewControllerAnimated:YES];
  return;
}
@end
