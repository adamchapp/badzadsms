//
//  MMLocation.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "BZLocation.h"
#import "Constants.h"

@implementation BZLocation

-(id)initWithName:(NSString *)title timestamp:(NSDate *)date coordinate:(CLLocationCoordinate2D)coordinate isVisible:(BOOL)visible;
{
    self = [super init];
    
    if ( self )
    {
        self.title = title;
        self.timestamp = date;
        self.coordinate = coordinate;
        self.isVisible = visible;
    }
    
    return self;
}

- (BOOL)isVisible {
    return _isVisible;
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    if ( !_subtitle ) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:BZReadableDateFormat];
        _subtitle = [formatter stringFromDate:self.timestamp];
    }
    return _subtitle;
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

@end
