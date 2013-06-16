//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "URLParser.h"
#import "KMLParser.h"
#import "MapOverlay.h"
#import "UserLocation+Extensions.h"
#import "KMLLocation+Extensions.h"
#import "MapTileCollection+Extension.h"

@interface LocationModel : NSObject

- (void)addUserLocationFromURL:(NSURL *)url;
- (void)addUserLocationWithTitle:(NSString *)title sender:(NSString *)sender timestamp:(NSDate *)timestamp latitude:(double)latitude longitude:(double)longitude isVisible:(BOOL)isVisible;
- (void)removeUserLocation:(UserLocation *)location;

- (void)showUserLocation:(UserLocation *)location;
- (void)hideUserLocation:(UserLocation *)location;

- (UserLocation *)getUserLocationByName:(NSString *)name;

- (void)addKMLLocationFromURL:(NSURL *)url;
- (void)removeKMLLocation:(KMLLocation *)location;

- (void)showKMLLocation:(KMLLocation *)location;
- (void)hideKMLLocation:(KMLLocation *)location;

- (void)addMapTileCollectionWithName:(NSString *)name directoryPath:(NSString *)path isFlippedAxis:(BOOL)flipped;
- (void)removeMapTileCollection:(MapTileCollection *)location;

- (void)showMapTileCollection:(MapTileCollection *)location;
- (void)hideMapTileCollection:(MapTileCollection *)location;

- (NSArray *)userLocations;
- (NSArray *)kmlLocations;
- (NSArray *)mapTileCollections;

- (NSArray *)kmlLocationViews;
- (NSArray *)mapTileCollectionViews;

@end
