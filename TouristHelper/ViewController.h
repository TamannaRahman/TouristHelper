//
//  ViewController.h
//  TouristHelper
//
//  Created by CQUGSR on 24/08/2016.
//  Copyright © 2016 Tamanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"

#import <GoogleMaps/GoogleMaps.h>
#define GOOGLE_MAP_KEY @"AIzaSyAD8KazsELVJgNWYvmwaul3J432iU8HVH8"


@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) float currentLat;
@property (nonatomic) float currentLon;

@property (strong, nonatomic) NSMutableArray *pOIPlaceArray;
@property (nonatomic)double lat;
@property (nonatomic)double lon;
@property (nonatomic, strong)NSString *imageUrlString;
@property (nonatomic, strong)NSString *ID;
@property (nonatomic, strong)NSString *placeId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *vicinity;
@property (nonatomic, strong)NSString *phoneNumberString;

@end

