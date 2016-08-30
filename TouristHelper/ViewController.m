//
//  ViewController.m
//  TouristHelper
//
//  Created by CQUGSR on 24/08/2016.
//  Copyright © 2016 Tamanna. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<GMSMapViewDelegate>

@property(nonatomic, strong) GMSMapView *mapView;

@end

@implementation ViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [_locationManager requestWhenInUseAuthorization];
    
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
    
    
 
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_locationManager.location.coordinate.latitude
                                                                longitude:_locationManager.location.coordinate.longitude
                                                                     zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    
   /* // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    //marker.position = CLLocationCoordinate2DMake(_mapView.myLocation.coordinate.latitude, _mapView.myLocation.coordinate.longitude);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
*/
    
    for (Place *place in self.pOIPlaceArray) {
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(place.lat, place.lon);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = place.name;
        marker.snippet = place.vicinity;
        marker.map = self.mapView;
        NSLog(@"%f",place.lat);

    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
  //  NSLog(@"loc: %@", locations.lastObject);
    
    [_locationManager stopUpdatingLocation];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getListOfNearByInterestingLocation:locations.lastObject];
    });

   


 }


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
   // NSLog(@" location %@", newLocation);
    
    [_locationManager stopUpdatingLocation];
    //self.currentUserLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude
    //                                                      longitude:newLocation.coordinate.longitude];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getListOfNearByInterestingLocation:newLocation];
    });
}

- (void)getListOfNearByInterestingLocation:(CLLocation*)location{
    
    
    self.coordinate = location.coordinate;
    
    //&region=jp
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=500&types=all&sensor=true&key=%@", location.coordinate.latitude, location.coordinate.longitude, GOOGLE_MAP_KEY];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        
        if (!connectionError) {
            
            if (data) {
                
                NSError *errorJson=nil;
                NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
               // NSLog(@"responseDict: %@", responseDict);
                
                [self parseForPOI:responseDict];
            }
        }
        
    }];
}


- (void)parseForPOI:(NSDictionary*)pOIDict{
    
    
    if ([pOIDict objectForKey:@"results"]) {
        
        NSArray *pOIDictArray = [pOIDict objectForKey:@"results"];
        
        
        self.pOIPlaceArray = [[NSMutableArray alloc]initWithCapacity:pOIDictArray.count];
        
        NSMutableArray *pOIArray = [[NSMutableArray alloc]initWithCapacity:pOIDictArray.count];
        for (NSDictionary *pOI in pOIDictArray) {
            
            
            Place *place = [[Place alloc]init];
            
            place.imageUrlString = [pOI objectForKey:@"icon"];
            place.ID = [pOI objectForKey:@"id"];
            place.name = [pOI objectForKey:@"name"];
            place.placeId = [pOI objectForKey:@"place_id"];
            
            place.vicinity = [pOI objectForKey:@"vicinity"];
            NSDictionary *locationDict = [pOI objectForKey:@"geometry"];
            
            place.lat = [[[locationDict objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
            place.lon = [[[locationDict objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            
            [pOIArray addObject:place];
            
            NSLog(@"%@", place.imageUrlString);

        }
        
        [self.pOIPlaceArray addObjectsFromArray:pOIArray];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
