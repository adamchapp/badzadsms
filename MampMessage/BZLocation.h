//
//  MMLocation.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BZLocation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) BOOL isVisible;

- (id)initWithName:(NSString *)title timestamp:(NSDate *)date coordinate:(CLLocationCoordinate2D)coordinate isVisible:(BOOL)visible;

@end
