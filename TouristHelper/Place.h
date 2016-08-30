//
//  Place.h
//  TouristHelper
//
//  Created by CQUGSR on 30/08/2016.
//  Copyright © 2016 Tamanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic)double lat;
@property (nonatomic)double lon;
@property (nonatomic, strong)NSString *imageUrlString;
@property (nonatomic, strong)NSString *ID;
@property (nonatomic, strong)NSString *placeId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *vicinity;
@property (nonatomic, strong)NSString *phoneNumberString;


@end
