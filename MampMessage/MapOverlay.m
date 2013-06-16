//
//  MapOverlay.m
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import "MapOverlay.h"
#import "MapTile.h"

#define OVERLAY_SIZE 256.0

static NSInteger zoomScaleToZoomLevel(MKZoomScale scale)
{
    // Conver an MKZoomScale to a zoom level where level 0 contains
    // four square tiles.
    double numberOfTilesAt1_0 = MKMapSizeWorld.width / OVERLAY_SIZE;
    
    //Add 1 to account for virtual tile
    NSInteger zoomLevelAt1_0 = log2(numberOfTilesAt1_0);
    NSInteger zoomLevel = MAX(0, zoomLevelAt1_0 + floor(log2f(scale) + 0.5));
    return zoomLevel;
}

@interface MapOverlay ()
{
    //NB IMPORTANT - Some maps use a flipped y axis 
    BOOL isFlipped;
}

@end

@implementation MapOverlay

- (id)initWithDirectory:(NSString *)directory shouldFlipOrigin:(BOOL)flipOrigin
{
    
    if (self = [super init])
    {
        isFlipped = flipOrigin;
        NSString *filePath = nil;
        NSMutableSet *pathSet = [NSMutableSet set];
        NSInteger minZ = INT_MAX;

        baseDirectory = directory;
        
        // Find available tiles.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *directoryEnum = [fileManager enumeratorAtPath:directory];
        
        while (filePath = [directoryEnum nextObject])
        {
            if (NSOrderedSame == [[filePath pathExtension] caseInsensitiveCompare:@"png"])
            {
                NSArray *components = [[filePath stringByDeletingPathExtension] pathComponents];
                
                if ([components count] == 3) 
                {
                    NSInteger z = [[components objectAtIndex:0] integerValue];
                    NSInteger x = [[components objectAtIndex:1] integerValue];
                    NSInteger y = [[components objectAtIndex:2] integerValue];
                    
                    NSString *tileKey = [[ NSString alloc] initWithFormat:@"%d/%d/%d", z, x, y];
                    
                    [pathSet addObject:tileKey];
                    
                    if (z < minZ)
                    {
                        minZ = z;
                    }
                }
            }
        }
        
        if ([pathSet count] == 0)
        {
            NSLog(@"Could not find any tiles at %@", directory);
            return nil;
        }
        
        // Define the bounding map rect.
        NSInteger minX = INT_MAX;
        NSInteger minY = INT_MAX;
        NSInteger maxX = 0;
        NSInteger maxY = 0;
        
        for (NSString *tileKey in pathSet)
        {
            NSArray *components = [tileKey pathComponents];
            
            NSInteger z = [[components objectAtIndex:0] integerValue];
            NSInteger x = [[components objectAtIndex:1] integerValue];
            NSInteger y = [[components objectAtIndex:2] integerValue];
            
            if (z == minZ)
            {
                minX = MIN(minX, x);
                minY = MIN(minX, y);
                maxX = MAX(maxX, x);
                maxY = MAX(maxY, y);
            }
        }
        
        // The first tile in the y direction is at the bottom, while
        // the first point is in the upper left.  Flip the y direction
        // to get the tiles in order.
        
        NSInteger zTiles = pow(2, minZ);
        double zSize = zTiles * OVERLAY_SIZE;
        double minZZoomScale = zSize / MKMapSizeWorld.width;
        
        double x0;
        double x1;
        double y0;
        double y1;
        
        if ( isFlipped ) {
            NSInteger flippedMinY = abs(minY + 1 - zTiles);
            NSInteger flippedMaxY = abs(maxY + 1 - zTiles);
            
            x0 = (minX * OVERLAY_SIZE) / minZZoomScale;
            x1 = ((maxX + 1) * OVERLAY_SIZE) / minZZoomScale;
            y0 = (flippedMaxY * OVERLAY_SIZE) / minZZoomScale;
            y1 = ((flippedMinY + 1) * OVERLAY_SIZE) / minZZoomScale;
        } else {
            x0 = (minX * OVERLAY_SIZE) / minZZoomScale;
            x1 = ((maxX + 1) * OVERLAY_SIZE) / minZZoomScale;
            y0 = (minY * OVERLAY_SIZE) / minZZoomScale;
            y1 = ((maxY + 1) * OVERLAY_SIZE) / minZZoomScale;
        }
        
        boundingRect = MKMapRectMake(x0, y0, x1 - x0, y1 - y0);
        
        paths = pathSet;
    }
    return self;
}

- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale
{
    NSInteger z = zoomScaleToZoomLevel(scale);
    
    NSMutableArray *tiles = nil;
    
    // The number of tiles either wide or high.
    
    NSInteger zTiles = pow(2, z);
    
    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / OVERLAY_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / OVERLAY_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / OVERLAY_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / OVERLAY_SIZE);
    
    for(NSInteger x = minX; x <= maxX; x++)
    {
        for(NSInteger y = minY; y <=maxY; y++)
        {
            // Flip the y index to properly reference overlay files.
            NSInteger flippedY = abs(y + 1 - zTiles);

            // Use flippedY or original Y value (OSGEO or OpenGIS / WMTS)
            NSInteger yValue = ( isFlipped ) ? flippedY : y;
            
            NSString *tileKey = [[NSString alloc] initWithFormat:@"%d/%d/%d", z, x, yValue];
                        
            if ([paths containsObject:tileKey])
            {
                if (!tiles)
                {
                    tiles = [NSMutableArray array];
                }
                MKMapRect frame = MKMapRectMake((double)(x * OVERLAY_SIZE) / scale, (double)(y * OVERLAY_SIZE) / scale, OVERLAY_SIZE / scale, OVERLAY_SIZE / scale);
                
                NSString *path = [[NSString alloc] initWithFormat:@"%@/%@.png", baseDirectory, tileKey];
                MapTile *tile = [[MapTile alloc] initWithFrame:frame path:path];
                [tiles addObject:tile];
            }
        }
    }
    return tiles;
}

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingRect), MKMapRectGetMidY(boundingRect)));
}

- (MKMapRect)boundingMapRect
{
    return boundingRect;
}

@end
