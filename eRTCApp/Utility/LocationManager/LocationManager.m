//
//  LocationManager.m
//  eRTCApp
//
//  Created by jayant patidar on 09/10/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager (){
    LocationCompletion _block;
    BOOL hasLastLocation;
    CLLocation *lastLocation;
}
@end
@implementation LocationManager

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        [self locationManager];
    }
    return self;
}

-(void)setCompletion:(LocationCompletion)completion {
    _block = completion;
}

-(BOOL)isLocationServiceEnabled{
    return [CLLocationManager locationServicesEnabled];
}

-(void)startLocationUpdate{
    
    if ([CLLocationManager locationServicesEnabled])
    {
       
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusDenied) {
            NSString *title;
            title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
            NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            NSError *error = [[NSError alloc] initWithDomain:@"ripbull.location" code:200 userInfo:@{NSLocalizedDescriptionKey: title}];
            if (_block != NULL){
                CLLocation *location;
                _block(location, error);
            }
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }else {
            if (locationManager.location == NULL){
                locationManager.delegate = self;
                locationManager.distanceFilter = kCLDistanceFilterNone;
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [locationManager startUpdatingLocation];
            }else {
                NSError *error;
                 _block(locationManager.location, error);
            }
        }
    }else {
        NSError *error = [[NSError alloc] initWithDomain:@"ripbull.location" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Location services are off"}];
         CLLocation *location;
        _block(location, error);
    }
    
}
- (void) locationManager
{
    hasLastLocation = FALSE;
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled])
    {
       
       
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 0;
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestAlwaysAuthorization];
        }
        [locationManager startUpdatingLocation];
        
    }
}

- (void)requestWhenInUseAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        NSError *error = [[NSError alloc] initWithDomain:@"ripbull.location" code:200 userInfo:@{NSLocalizedDescriptionKey: title}];
        if (_block != NULL){
            CLLocation *location;
            _block(location, error);
        }
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    if (_block != NULL){
        CLLocation *location;
        _block(location, error);
    }
    [manager stopUpdatingLocation];
    //    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [locationManager startUpdatingLocation];
        }
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    hasLastLocation = TRUE;
    lastLocation = newLocation;
    if (_block != NULL){
        NSError *error;
        _block(newLocation, error);
         [manager stopUpdatingLocation];
        manager.delegate = nil;
    }
   
}


@end
