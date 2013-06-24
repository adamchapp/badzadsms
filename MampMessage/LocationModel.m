//
//  LocationModel.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "LocationModel.h"
#import "Constants.h"

@interface LocationModel ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) URLParser *urlParser;
@property (nonatomic, strong) KMLParser *kmlParser;

@end

@implementation LocationModel

//////////////////////////////////////////////////////////////
#pragma mark  - Locations
//////////////////////////////////////////////////////////////

/**
 Checks for an exising location and compares the timestamp to see 
 if the proposed location is newer than the existing one
 */
- (BOOL)isLocationValid:(NSString *)title timestamp:(NSDate *)timestamp
{
    Location *previousLocation = [[Location MR_findByAttribute:@"title" withValue:title inContext:self.context] lastObject];
    
    if ( !previousLocation ) return YES;
    
    if ( [previousLocation isKindOfClass:[UserLocation class]] ) {
        NSDate *previousDate = [(UserLocation *)previousLocation timestamp];
        return ( [self isDate:timestamp laterThanPreviousDate:previousDate] ) ? YES : NO;
        
    } else if ( [previousLocation isKindOfClass:[KMLLocation class]] ) {
        
    } else if ( [previousLocation isKindOfClass:[MapTileCollection class]] ) {
        
    }
    
    return YES;
}

- (BOOL)isDate:(NSDate *)newDate laterThanPreviousDate:(NSDate *)previousDate {
    //new date is earlier than previousDate
    if ([newDate compare:previousDate] == NSOrderedAscending) {
        return NO;
    } else if ([newDate compare:previousDate] == NSOrderedDescending) {
        return YES;
    }
    return YES;
}

- (void)showAlertView:(NSString *)locationTitle
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to replace the current location for %@ with an older one?", locationTitle];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setDelegate:self];
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        self.confirmBlock();
    }
}

- (void)addUserLocationFromURL:(NSURL *)url
{
    NSLog(@"[LM] Adding new user location from URL");
    self.urlParser = [[URLParser alloc] initWithURLString:url.absoluteString];
    
    NSString *title = [[self.urlParser valueForVariable:@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSString *timeStampString = [self.urlParser valueForVariable:@"timestamp"];
    NSString *sender = [self.urlParser valueForVariable:@"sender"];
    
    NSDate *timestamp = [self.formatter dateFromString:timeStampString];
    
    double latitude = [[self.urlParser valueForVariable:@"lat"] doubleValue];
    double longitude = [[self.urlParser valueForVariable:@"long"] doubleValue];
    
    __weak typeof(self) weakSelf = self;
    
    self.confirmBlock = ^ {
        [weakSelf addUserLocationWithTitle:title sender:sender timestamp:timestamp latitude:latitude longitude:longitude selected:YES];
    };
    
    if ( [self isLocationValid:title timestamp:timestamp] ) {
        self.confirmBlock();
    } else {
        [self showAlertView:title];
    }
}

- (void)addUserLocationWithTitle:(NSString *)title
                          sender:(NSString *)sender
                       timestamp:(NSDate *)timestamp
                        latitude:(double)latitude
                       longitude:(double)longitude
                       selected:(BOOL)selected
{
    NSDateFormatter *readableFormatter = [[NSDateFormatter alloc] init];
    [readableFormatter setDateFormat:BZReadableDateFormat];
    
    UserLocation *previousLocation = [[UserLocation MR_findByAttribute:@"title" withValue:title inContext:self.context] lastObject];
    UserLocation *newLocation;
    
    if ( previousLocation ) {
        newLocation = previousLocation;
    } else {
        newLocation = [UserLocation MR_createInContext:self.context];
    }
    
    newLocation.sender = sender;
    newLocation.title = title;
    newLocation.subtitle = [readableFormatter stringFromDate:timestamp];
    newLocation.timestamp = timestamp;
    newLocation.latitude = [NSNumber numberWithDouble:latitude];
    newLocation.longitude = [NSNumber numberWithDouble:longitude];
    newLocation.selected = [NSNumber numberWithBool:YES];
        
    self.confirmBlock = nil;
    
    [self setDestination:newLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeUserLocation:(UserLocation *)location
{
    [location MR_deleteInContext:self.context];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)setUserLocationAsSelected:(UserLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:YES]];    
}

- (void)setUserLocationAsDeselected:(UserLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:NO]];
}

- (UserLocation *)getUserLocationByName:(NSString *)name
{
    UserLocation *location = [UserLocation MR_findFirstByAttribute:@"title" withValue:name];
    return location;
}

- (void)setDestination:(Location *)destination
{
    NSLog(@"[LM] Setting destination");
    
    if ( [self.currentDestination isKindOfClass:[UserLocation class]] ) {
        [self setUserLocationAsDeselected:(UserLocation *)self.currentDestination];
    } else {
        [self setKMLLocationAsDeselected:(KMLLocation *)self.currentDestination];
    }
    
    if ( destination ) {
        if ([destination isKindOfClass:[UserLocation class]] ) {
            [self setUserLocationAsSelected:(UserLocation *)destination];
        } else {
            [self setKMLLocationAsSelected:(KMLLocation *)destination];
        }
    }
    
    self.currentDestination = destination;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

//////////////////////////////////////////////////////////////
#pragma mark  - KML Locations
//////////////////////////////////////////////////////////////

- (void)addKMLLocationFromURL:(NSURL *)url
{        
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *kmlAnnotations = [self.kmlParser points];
    
    for ( id<MKAnnotation>annotation in kmlAnnotations ) {
        
        KMLLocation *location;
        KMLLocation *previousLocation = [[KMLLocation MR_findByAttribute:@"title" withValue:annotation.title inContext:self.context] lastObject];
        
        if ( previousLocation ) {
            location = previousLocation;
        } else {
            location = [KMLLocation MR_createInContext:self.context];
        }
        
        location.title = annotation.title;
        location.subtitle = annotation.subtitle;
        location.latitude = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        location.longitude = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        location.selected = [NSNumber numberWithBool:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeKMLLocation:(KMLLocation *)location
{
    [location MR_deleteInContext:self.context];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)setKMLLocationAsSelected:(KMLLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:YES]];    
}

- (void)setKMLLocationAsDeselected:(KMLLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:NO]];
}

//////////////////////////////////////////////////////////////
#pragma mark  - MapTile Collections
//////////////////////////////////////////////////////////////

- (void)addMapTileCollectionWithName:(NSString *)name directoryPath:(NSString *)path isFlippedAxis:(BOOL)flipped
{
    MapTileCollection *collection = [MapTileCollection MR_createInContext:self.context];
    collection.title = name;
    collection.directoryPath = path;
    collection.isVisible = [NSNumber numberWithBool:NO];
    collection.isFlippedAxis = [NSNumber numberWithBool:flipped];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"MapTileCollection was added in persistent store");
        }
        else {
            NSLog(@"MapTileCollection was not added");
        }
    }];
}

- (void)removeMapTileCollection:(MapTileCollection *)location
{
    [location MR_deleteInContext:self.context];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"MapTileCollection was deleted from persistent store");
        }
        else {
            NSLog(@"MapTileCollection was not deleted");
        }
    }];
}

- (void)showMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZMapTileCollectionLoaded object:nil];
}

- (void)hideMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZMapTileCollectionLoaded object:nil];
}

- (void)saveContext {
    if ( [self.context hasChanges] ) {
        [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if ( success ) {
                NSLog(@"all items were saved successfully");
            }
            else {
                NSLog(@"there was an error saving one or more of the items : %@", error.debugDescription);
            }
        }];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)context {
    if ( !_context ) {
        _context = [NSManagedObjectContext MR_contextForCurrentThread];
    }
    return _context;
}

- (NSDateFormatter *)formatter {
    if ( !_formatter ) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:BZDateFormat];
    }
    return _formatter;
}


- (NSArray *)userLocations {
    NSArray *_userLocations = [UserLocation MR_findAllSortedBy:@"timestamp" ascending:YES inContext:self.context];
    return _userLocations;
}

- (NSArray *)kmlLocations {
    NSArray *_kmlLocations = [KMLLocation MR_findAllSortedBy:@"title" ascending:YES inContext:self.context];
    return _kmlLocations;
}

- (NSArray *)mapTileCollections {
    NSArray *_mapTileCollections = [MapTileCollection MR_findAllSortedBy:@"title" ascending:YES inContext:self.context];
    return _mapTileCollections;
}

- (NSArray *)mapTileCollectionViews {
    
    NSArray *tileCollections = [MapTileCollection MR_findAllSortedBy:@"title" ascending:YES inContext:self.context];
    
    NSMutableArray *collectionViews = [NSMutableArray arrayWithCapacity:[tileCollections count]];
    
    for ( MapTileCollection *collection in tileCollections ) {
        if ( [collection.isVisible boolValue] ) {
            NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:collection.directoryPath];
            
            MapOverlay *overlay = [[MapOverlay alloc] initWithDirectory:tileDirectory shouldFlipOrigin:[collection.isFlippedAxis boolValue]];
            
            [collectionViews addObject:overlay];
        }
    }
    
    return collectionViews;
}

//////////////////////////////////////////////////////////////
#pragma mark  - Utility methods
//////////////////////////////////////////////////////////////

- (NSString *)makeKeyFromUserLocation:(UserLocation *)location
{
    return [NSString stringWithFormat:@"%@", location.title];
}

- (NSString *)makeKeyFromKMLLocation:(KMLLocation *)location
{
    return [NSString stringWithFormat:@"%@", location.title];
}

@end
