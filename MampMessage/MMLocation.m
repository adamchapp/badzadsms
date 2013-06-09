//
//  MMLocation.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MMLocation.h"

@implementation MMLocation

-(id)initWithName:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if ( self )
    {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
    }
    
    return self;
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtitle;
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"BadZadPlacemark"];
    return annotationView;
}

@end
