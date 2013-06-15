//
//  MapOverlay.h
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapOverlay : NSObject <MKOverlay>
{
    NSString *baseDirectory;
    MKMapRect boundingRect;
    NSSet *paths;
}

// Initializes the overlay with a directory containing map tile images.
- (id)initWithDirectory:(NSString *)directory shouldFlipOrigin:(BOOL)flipOrigin;

// Returns an array of image tiles for the current map rectangle and zoom scale.
- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

@end
