//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLParser.h"
#import "UserLocation+Extensions.h"
#import "KMLLocation+Extensions.h"

@interface LocationModel : NSObject

- (void)addUserLocationFromURL:(NSURL *)url;
- (void)removeUserLocation:(UserLocation *)location;

- (void)showUserLocation:(UserLocation *)location;
- (void)hideUserLocation:(UserLocation *)location;

- (UserLocation *)getUserLocationByName:(NSString *)name;

- (void)addKMLLocationFromURL:(NSURL *)url;
- (void)removeKMLAnnotation:(KMLLocation *)location;

- (void)showKMLLocation:(KMLLocation *)location;
- (void)hideKMLLocation:(KMLLocation *)location;

- (NSArray *)userLocations;
- (NSArray *)kmlLocations;

@end
