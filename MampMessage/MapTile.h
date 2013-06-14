//
//  MapTile.h
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapTile : NSObject
{
    NSString *path;
    MKMapRect frame;
}

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) MKMapRect frame;

- (id) initWithFrame:(MKMapRect)tileFrame path:(NSString *)tilePath;

@end
