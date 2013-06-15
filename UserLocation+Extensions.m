//
//  UserLocation+Extensions.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "UserLocation+Extensions.h"

@implementation UserLocation (Extensions)

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

@end
