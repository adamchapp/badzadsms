//
//  Location+Extensions.m
//  MapMessage
//
//  Created by Adam Chappell on 23/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "Location+Extensions.h"

@implementation Location (Extensions)

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

@end
