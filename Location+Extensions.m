//
//  Location+Extensions.m
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "Location+Extensions.h"

@implementation Location (Extensions)

- (id)initWithName:(NSString *)title timestamp:(NSDate *)date coordinate:(CLLocationCoordinate2D)coordinate isVisible:(BOOL)visible
{
    self = [super init];
    
    if ( self )
    {
        self.title = title;
        self.timestamp = date;
        self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
        self.isVisible = [NSNumber numberWithBool:visible];
    }
    
    return self;
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

@end
