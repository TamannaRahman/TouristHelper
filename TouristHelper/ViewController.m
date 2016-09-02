//
//  ViewController.m
//  TouristHelper
//
//  Created by CQUGSR on 24/08/2016.
//  Copyright © 2016 Tamanna. All rights reserved.
//

#import "ViewController.h"
@import GoogleMaps;

#define GOOGLE_MAP_KEY @"AIzaSyAD8KazsELVJgNWYvmwaul3J432iU8HVH8"


@interface ViewController ()<GMSMapViewDelegate>

@property(nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *placesArrayToSort;
@property (nonatomic, strong) NSArray *allPlacesArray;

@end

@implementation ViewController{
    GMSPolyline *polyline;
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
    
    
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    [_locationManager stopUpdatingLocation];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.userLocation = locations.lastObject;
        [self getListOfNearByInterestingLocation:locations.lastObject];
    });
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [_locationManager stopUpdatingLocation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.userLocation = newLocation;
        [self getListOfNearByInterestingLocation:newLocation];
    });
}

- (void)getListOfNearByInterestingLocation:(CLLocation*)location{
    
    
    self.coordinate = location.coordinate;
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%lf,%lf&radius=1000&types=point_of_interest&key=%@&language=ja", location.coordinate.latitude, location.coordinate.longitude, GOOGLE_MAP_KEY];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        
        if (!connectionError) {
            
            if (data) {
                
                NSError *errorJson=nil;
                NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
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
            
        }
        self.allPlacesArray = [NSArray arrayWithArray:pOIArray];
        [self.pOIPlaceArray addObjectsFromArray:pOIArray];
        
        [self showMap];
    }
    
}


- (void)showMap{
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.coordinate.latitude
                                                            longitude:self.coordinate.longitude
                                                                 zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    self.mapView.delegate = self;
    
    
    for (Place *place in self.pOIPlaceArray) {
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(place.lat, place.lon);
        marker.title = place.name;
        marker.snippet = place.vicinity;
        marker.map = self.mapView;        
    }
}

- (CLLocation*)calculatedMostShortestPoint:(CLLocation*)locationFrom{

    NSMutableArray *placeArray = [[NSMutableArray alloc]initWithCapacity:self.placesArrayToSort.count];
    
    for (Place *place in self.placesArrayToSort) {
        
        if (!(locationFrom.coordinate.latitude == place.lat && locationFrom.coordinate.longitude == place.lon)) {

            [placeArray addObject:place];
        }
    }
    
    [self.placesArrayToSort removeAllObjects];
    [self.placesArrayToSort addObjectsFromArray:placeArray];
    
    
    Place *place = [self.placesArrayToSort firstObject];
    
    CLLocation *locationToAdd = [[CLLocation alloc] initWithLatitude:place.lat longitude:place.lon];
    CLLocationDistance distance = [locationFrom distanceFromLocation:locationToAdd];;

    
    for (Place *place in self.placesArrayToSort) {
        
        CLLocation *locationTo = [[CLLocation alloc] initWithLatitude:place.lat longitude:place.lon];
        
        CLLocationDistance tempDistance = [locationFrom distanceFromLocation:locationTo];
        
        if (tempDistance < distance){
            distance = tempDistance;
            locationToAdd = locationTo;
        }
        
    }
    return locationToAdd;
    
}



-(void) drawLineOnMap{
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    _locationDic = [[NSMutableDictionary alloc] init];

    [path addCoordinate:_startLocation.coordinate];
    
    // Remove Place from the arrayOf Place which user has been selected
    Place *startPlace = nil;
    for (Place *place in self.pOIPlaceArray) {
        
        if (_startLocation.coordinate.latitude == place.lat && _startLocation.coordinate.longitude == place.lon) {
            startPlace = place;
        }
    }
    [self.pOIPlaceArray removeObject:startPlace];
    
    
    
    self.placesArrayToSort = [[NSMutableArray alloc]initWithArray:self.pOIPlaceArray];
    
    CLLocation *locationToStart = _startLocation;
    
    for (int i = 0; i < self.pOIPlaceArray.count; i++){
        
        locationToStart = [self calculatedMostShortestPoint:locationToStart];
        
        [path addCoordinate:locationToStart.coordinate];
    }
    
    [path addCoordinate:_userLocation.coordinate];
    [path addCoordinate:_startLocation.coordinate];
    
    
    polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 5.f;
    polyline.geodesic = NO;
    polyline.map = self.mapView;
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    
    self.mapView.selectedMarker = marker;
    [self.pOIPlaceArray removeAllObjects];
    [self.pOIPlaceArray addObjectsFromArray:self.allPlacesArray];
    
    _selectedMarkerLat = marker.position.latitude;
    _selectedMarkerLon = marker.position.longitude;
    _startLocation = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
    
    [polyline setMap:nil];
    
    [self drawLineOnMap];
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
