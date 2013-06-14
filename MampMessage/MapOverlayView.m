//
//  MapOverlayView.m
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import "MapOverlayView.h"
#import "MapOverlay.h"
#import "MapTile.h"

@implementation MapOverlayView

@synthesize overlayAlpha;

- (id)initWithOverlay:(id<MKOverlay>)overlay
{
    if (self = [super initWithOverlay:overlay])
    {
        overlayAlpha = 0.75;
    }
    return self;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    // Return YES if there are some tiles in this rect at this zoom scale
    MapOverlay *mapOverlay = (MapOverlay *)self.overlay;
    
    NSArray *tilesInRect = [mapOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    return [tilesInRect count] > 0;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    MapOverlay *mapOverlay = (MapOverlay *)self.overlay;
    
    // Get a list of one or more tile images for this map's rect.

    NSArray *rectTiles = [mapOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    
    CGContextSetAlpha(context, overlayAlpha);
    
    for (MapTile *tile in rectTiles)
    {
        // draw each tile in its frame
        CGRect rect = [self rectForMapRect:tile.frame];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:tile.path];
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1 / zoomScale, 1 / zoomScale);
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
        CGContextRestoreGState(context);
    }
}

@end
