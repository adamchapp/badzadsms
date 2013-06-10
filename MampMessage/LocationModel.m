//
//  LocationModel.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "LocationModel.h"
#import "Constants.h"

@implementation LocationModel

//////////////////////////////////////////////////////////////
#pragma mark  - BZ Locations
//////////////////////////////////////////////////////////////

- (void)addLocation:(BZLocation *)location
{
    NSLog(@"adding location to model");
    [self.coordinates addObject:location];
    [self.coordinateDisplayMap setValue:[NSNumber numberWithBool:YES] forKey:[self makeKeyFromLocation:location]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeLocationAtIndex:(NSInteger)index
{
    [self.coordinates removeObjectAtIndex:index];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showLocation:(BZLocation *)location
{
    [self.coordinateDisplayMap setValue:[NSNumber numberWithBool:YES] forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideLocation:(BZLocation *)location
{
    [self.coordinateDisplayMap setValue:[NSNumber numberWithBool:NO] forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark  - BZ Overlays
//////////////////////////////////////////////////////////////

- (void)addOverlay:(BZOverlay *)overlay
{
    [self.overlays addObject:overlay];
    [self.overlayDisplayMap setValue:[NSNumber numberWithBool:YES] forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeOverlayAtIndex:(NSInteger)index
{
    [self.overlays removeObjectAtIndex:index];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showOverlay:(BZOverlay *)overlay
{
    [self.overlayDisplayMap setValue:[NSNumber numberWithBool:YES] forKey:[self makeKeyFromOverlay:overlay]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideOverlay:(BZOverlay *)overlay
{
    [self.overlayDisplayMap setValue:[NSNumber numberWithBool:NO] forKey:[self makeKeyFromOverlay:overlay]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (NSMutableDictionary *)coordinateDisplayMap
{
    if ( !_coordinateDisplayMap ) {
        _coordinateDisplayMap = [[NSMutableDictionary alloc] init];
    }
    return _coordinateDisplayMap;
}

- (NSMutableArray *)coordinates
{
    if ( !_coordinates ) {
        _coordinates = [NSMutableArray array];
    }
    return _coordinates;
}

- (NSMutableDictionary *)overlayDisplayMap
{
    if ( !_overlayDisplayMap ) {
        _overlayDisplayMap = [[NSMutableDictionary alloc] init];
    }
    return _overlayDisplayMap;
}

- (NSMutableArray *)overlays
{
    if ( !_overlays ) {
        _overlays = [NSMutableArray array];
    }
    return _overlays;
}

//////////////////////////////////////////////////////////////
#pragma mark  - Utility methods
//////////////////////////////////////////////////////////////

- (NSString *)makeKeyFromLocation:(BZLocation *)location
{
    return [NSString stringWithFormat:@"%@|%@|%f|%f", location.title, location.subtitle, location.coordinate.latitude, location.coordinate.longitude];
}

#warning Overlay key is title only, which means there could be duplicates
- (NSString *)makeKeyFromOverlay:(BZOverlay *)overlay
{
    return [NSString stringWithFormat:@"%@", overlay.title];
}

@end
