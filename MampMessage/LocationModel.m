//
//  LocationModel.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel

- (void)addLocation:(BZLocation *)location
{
    [self.coordinates addObject:location];
    [self.coordinateDisplayMap setValue:[NSNumber numberWithBool:YES] forKey:location.title];
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

@end
