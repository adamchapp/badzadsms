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

- (void)addLocation:(Location *)location
{
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeLocation:(Location *)location
{
    [coordinateDictionary removeObjectForKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showLocation:(Location *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideLocation:(Location *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [coordinateDictionary setObject:location forKey:[self makeKeyFromLocation:location]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (Location *)getLocationByName:(NSString *)name
{
    return [coordinateDictionary objectForKey:name];
}

//////////////////////////////////////////////////////////////
#pragma mark  - BZ Overlays
//////////////////////////////////////////////////////////////

- (void)addOverlay:(Overlay *)overlay
{
    [overlayDictionary setObject:overlay forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeOverlay:(Overlay *)overlay
{
    [overlayDictionary removeObjectForKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showOverlay:(Overlay *)overlay
{
    [overlay setIsVisible:[NSNumber numberWithBool:YES]];
    [overlayDictionary setObject:overlay forKey:[self makeKeyFromOverlay:overlay]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideOverlay:(Overlay *)overlay
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

- (NSString *)makeKeyFromLocation:(Location *)location
{
    return [NSString stringWithFormat:@"%@", location.title];
}

- (NSString *)makeKeyFromOverlay:(Overlay *)overlay
{
    return [NSString stringWithFormat:@"%@", overlay.title];
}

@end
