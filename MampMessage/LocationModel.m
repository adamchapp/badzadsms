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

- (NSString *)makeKeyFromLocation:(BZLocation *)location
{
    return [NSString stringWithFormat:@"%@|%@|%f|%f", location.title, location.subtitle, location.coordinate.latitude, location.coordinate.longitude];
}

@end
