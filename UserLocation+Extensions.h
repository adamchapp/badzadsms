//
//  UserLocation+Extensions.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "UserLocation.h"

@interface UserLocation (Extensions)

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString *)title timestamp:(NSDate *)date coordinate:(CLLocationCoordinate2D)coordinate isVisible:(BOOL)visible;

@end
