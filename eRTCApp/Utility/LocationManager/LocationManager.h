//
//  LocationManager.h
//  eRTCApp
//
//  Created by jayant patidar on 09/10/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LocationCompletion)(CLLocation *location, NSError *error);

@interface LocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) CLLocation *currentLocation;


-(void) setCompletion:(LocationCompletion) completion;
-(BOOL)isLocationServiceEnabled;
-(void) startLocationUpdate;


@end

NS_ASSUME_NONNULL_END
