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

-(id)init {
    
    self = [super init];
    
    if ( self ) {
        coordinateDictionary = [[NSMutableDictionary alloc] init];
        overlayDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addLocation:(BZLocation *)location
{
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeLocation:(BZLocation *)location
{
    [coordinateDictionary removeObjectForKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showLocation:(BZLocation *)location
{
    [location setIsVisible:YES];
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideLocation:(BZLocation *)location
{
    [location setIsVisible:NO];
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark  - BZ Overlays
//////////////////////////////////////////////////////////////

- (void)addOverlay:(BZOverlay *)overlay
{
    [overlayDictionary setObject:overlay forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeOverlay:(BZOverlay *)overlay
{
    [overlayDictionary removeObjectForKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showOverlay:(BZOverlay *)overlay
{
    [overlay setIsVisible:YES];
    [overlayDictionary setObject:overlay forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideOverlay:(BZOverlay *)overlay
{
    [overlay setIsVisible:NO];
    [overlayDictionary setObject:overlay forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (NSArray *)coordinates {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"timestamp"
                                        ascending:YES
                                        selector:@selector(compare:)];

    NSArray *coordinates = [[coordinateDictionary allValues] sortedArrayUsingDescriptors:@[dateDescriptor]];
    
    return coordinates;
}

- (NSArray *)overlays {
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"title"
                                        ascending:YES];
    
    NSArray *overlays = [[overlayDictionary allValues] sortedArrayUsingDescriptors:@[nameDescriptor]];
    
    return overlays;
}

//////////////////////////////////////////////////////////////
#pragma mark  - Utility methods
//////////////////////////////////////////////////////////////

- (NSString *)makeKeyFromLocation:(BZLocation *)location
{
    return [NSString stringWithFormat:@"%@", location.title];
}

- (NSString *)makeKeyFromOverlay:(BZOverlay *)overlay
{
    return [NSString stringWithFormat:@"%@", overlay.title];
}

@end
