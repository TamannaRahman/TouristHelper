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



@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSMutableArray *pOIPlaceArray;
@property (nonatomic) double selectedMarkerLat;
@property (nonatomic) double selectedMarkerLon;
@property (strong, nonatomic) NSMutableDictionary *locationDic;
@property (nonatomic) CLLocation *startLocation;
@property (nonatomic) CLLocation *userLocation;

@end

