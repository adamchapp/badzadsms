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

typedef void (^ConfirmAddLocationBlock)(void);

@interface LocationModel : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) ConfirmAddLocationBlock confirmBlock;

- (void)addUserLocationFromURL:(NSURL *)url;
- (void)addUserLocationWithTitle:(NSString *)title sender:(NSString *)sender timestamp:(NSDate *)timestamp latitude:(double)latitude longitude:(double)longitude selected:(BOOL)selected;
- (void)removeUserLocation:(UserLocation *)location;

- (UserLocation *)getUserLocationByName:(NSString *)name;

- (void)setDestination:(Location *)destination;

- (void)addKMLLocationFromURL:(NSURL *)url;
- (void)removeKMLLocation:(KMLLocation *)location;

- (void)addMapTileCollectionWithName:(NSString *)name directoryPath:(NSString *)path isFlippedAxis:(BOOL)flipped;
- (void)removeMapTileCollection:(MapTileCollection *)location;

- (void)showMapTileCollection:(MapTileCollection *)location;
- (void)hideMapTileCollection:(MapTileCollection *)location;

- (NSArray *)userLocations;
- (NSArray *)kmlLocations;
- (NSArray *)mapTileCollections;

- (NSArray *)mapTileCollectionViews;

@property (nonatomic, strong) Location *currentDestination;

- (void)saveContext;

@end
