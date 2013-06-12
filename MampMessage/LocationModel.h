//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZLocation.h"
#import "BZOverlay.h"

@interface LocationModel : NSObject
{
    NSMutableDictionary *coordinateDictionary;
    NSMutableDictionary *overlayDictionary;
}

- (void)addLocation:(BZLocation *)location;
- (void)removeLocation:(BZLocation *)location;

- (void)showLocation:(BZLocation *)location;
- (void)hideLocation:(BZLocation *)location;

- (BZLocation *)getLocationByName:(NSString *)name;

- (void)addOverlay:(BZOverlay *)overlay;
- (void)removeOverlay:(BZOverlay *)overlay;

- (void)showOverlay:(BZOverlay *)overlay;
- (void)hideOverlay:(BZOverlay *)overlay;

- (NSArray *)coordinates;
- (NSArray *)overlays;

@end
