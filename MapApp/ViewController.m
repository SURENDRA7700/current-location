//
//  ViewController.m
//  MapApp
//
//  Created by Devan Raju on 08/09/15.
//  Copyright (c) 2015 First-tek. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define METERS_MILE 1609.344
#define METERS_FEET 3.28084

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView_Sample;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

NSString *latitude;
NSString *longitude;
CLLocationCoordinate2D currentCoordinate;
CLLocationCoordinate2D chnagedCoordinate;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView_Sample.delegate = self;
    self.locationManager.delegate = self;
     [[self mapView_Sample] setShowsUserLocation:YES];
    // we have to setup the location maanager with permission in later iOS versions
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager] startUpdatingLocation];
    
    currentCoordinate=[self getLocation];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView_Sample.showsUserLocation = YES;
    }
}


-(CLLocationCoordinate2D) getLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    self.locationManager.activityType = CLActivityTypeOtherNavigation;
    
    [self.locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [CLLocationManager locationServicesEnabled];
    
    CLLocation *location = [self.locationManager location];
    currentCoordinate = [location coordinate];
    
    latitude=[NSString stringWithFormat:@"%.8f", currentCoordinate.latitude];
    longitude=[NSString stringWithFormat:@"%.8f", currentCoordinate.longitude];
    
    return currentCoordinate;
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    currentCoordinate = [newLocation coordinate];
    
    if (currentLocation != nil) {
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentCoordinate.longitude]);
        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentCoordinate.latitude]);
    }
    [self.mapView_Sample setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    NSDictionary *userLoc=[[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSLog(@"Saved in lat %@",[userLoc objectForKey:@"lat"]);
    NSLog(@"Saved in long %@",[userLoc objectForKey:@"long"]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
     CLLocation *location = locations.lastObject;
    // zoom the map into the users current location
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2*METERS_MILE, 2*METERS_MILE);
    [[self mapView_Sample] setRegion:viewRegion animated:YES];
}


@end
