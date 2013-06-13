//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location+Extensions.h"
#import "Overlay+Extensions.h"

@interface LocationModel : NSObject
{
    NSMutableDictionary *coordinateDictionary;
    NSMutableDictionary *overlayDictionary;
}

- (void)addLocation:(Location *)location;
- (void)removeLocation:(Location *)location;

- (void)showLocation:(Location *)location;
- (void)hideLocation:(Location *)location;

- (Location *)getLocationByName:(NSString *)name;

- (void)addOverlay:(Overlay *)overlay;
- (void)removeOverlay:(Overlay *)overlay;

- (void)showOverlay:(Overlay *)overlay;
- (void)hideOverlay:(Overlay *)overlay;

- (NSArray *)coordinates;
- (NSArray *)overlays;

@end
