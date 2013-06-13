//
//  Location.m
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic title;
@dynamic subtitle;
@dynamic isVisible;
@dynamic timestamp;
@dynamic latitude;
@dynamic longitude;

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

@end
