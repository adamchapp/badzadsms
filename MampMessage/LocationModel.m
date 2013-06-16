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

- (BOOL)isLocationValid:(NSString *)title
{
//    Location *location = [self.creator locationFromURL:url parser:parser formatter:self.formatter];
//    
//    Location *previousLocation;// = [self.locationModel getLocationByName:location.title];
//    
//    if ( previousLocation ) {
//        
//        NSDate *previousDate = [previousLocation timestamp];
//        NSDate *newDate = [location timestamp];
//        
//        if ([previousDate compare:newDate] == NSOrderedDescending) {
//            return NO;
//        } else if ([previousDate compare:newDate] == NSOrderedAscending) {
//            return YES;
//        }
//    } else {
        return YES;
//    }
}

- (void)showAlertView:(NSString *)locationTitle
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to replace the current location for %@ with an older one?", locationTitle];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    //            completionBlock = ^{
    //                //[self addLocation:location];
    //            };
    
    [alertView show];
}

- (void)addUserLocationFromURL:(NSURL *)url
{
    self.urlParser = [[URLParser alloc] initWithURLString:url.absoluteString];
    
    NSString *title = [[self.urlParser valueForVariable:@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSString *timeStampString = [self.urlParser valueForVariable:@"timestamp"];
    NSString *sender = [self.urlParser valueForVariable:@"sender"];
    
    NSDate *timestamp = [self.formatter dateFromString:timeStampString];
    
    double latitude = [[self.urlParser valueForVariable:@"lat"] doubleValue];
    double longitude = [[self.urlParser valueForVariable:@"long"] doubleValue];
    
    [self addUserLocationWithTitle:title sender:sender timestamp:timestamp latitude:latitude longitude:longitude isVisible:YES];
}

- (void)addUserLocationWithTitle:(NSString *)title
                          sender:(NSString *)sender
                       timestamp:(NSDate *)timestamp
                        latitude:(double)latitude
                       longitude:(double)longitude
                       isVisible:(BOOL)isVisible
{
    NSDateFormatter *readableFormatter = [[NSDateFormatter alloc] init];
    [readableFormatter setDateFormat:BZReadableDateFormat];
    
    UserLocation *location = [UserLocation MR_createInContext:self.context];
    location.sender = sender;
    location.title = title;
    location.subtitle = [readableFormatter stringFromDate:timestamp];
    location.timestamp = timestamp;
    location.latitude = [NSNumber numberWithDouble:latitude];
    location.longitude = [NSNumber numberWithDouble:longitude];
    location.isVisible = [NSNumber numberWithBool:YES];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"item was saved to persistent store");
        }
        else {
            NSLog(@"item was not saved");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeUserLocation:(UserLocation *)location
{
    [location MR_deleteInContext:self.context];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"item was deleted from persistent store");
        }
        else {
            NSLog(@"item was not deleted");
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showUserLocation:(UserLocation *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"item show/hide was updated in persistent store (to show)");
        }
        else {
            NSLog(@"item show/hide was not updated");
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideUserLocation:(UserLocation *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"item show/hide was updated in persistent store (to hide)");
        }
        else {
            NSLog(@"item show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (UserLocation *)getUserLocationByName:(NSString *)name
{
    UserLocation *location = [UserLocation MR_findFirstByAttribute:@"title" withValue:name];
    return location;
}

//////////////////////////////////////////////////////////////
#pragma mark  - KML Locations
//////////////////////////////////////////////////////////////

- (void)addKMLLocationFromURL:(NSURL *)url
{
    
    NSString *filenameWithExtension = [url lastPathComponent];
    NSString *filename = [filenameWithExtension stringByDeletingPathExtension];
        
    KMLLocation *location = [KMLLocation MR_createInContext:self.context];
    location.title = filename;
    location.locationFilePath = url.path;
    location.isVisible = [NSNumber numberWithBool:YES];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"kmlLocation was saved in persistent store");
        }
        else {
            NSLog(@"kmlLocation was not saved");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeKMLLocation:(KMLLocation *)location
{
    [location MR_deleteInContext:self.context];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"kmlLocation was deleted from persistent store");
        }
        else {
            NSLog(@"kmlLocation was not deleted");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showKMLLocation:(KMLLocation *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"kmlLocation show/hide was updated in persistent store (to show)");
        }
        else {
            NSLog(@"kmlLocation show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideKMLLocation:(KMLLocation *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"kmlLocation show/hide was updated in persistent store (to hide)");
        }
        else {
            NSLog(@"kmlLocation show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
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
            NSLog(@"MapTileCollection was not delete");
        }
    }];
}

- (void)showMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"maptilecollection show/hide was updated in persistent store (to show)");
        }
        else {
            NSLog(@"maptilecollection show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"maptilecollection show/hide was updated in persistent store (to hide)");
        }
        else {
            NSLog(@"maptilecollection show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
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

- (NSArray *)kmlLocationViews {
    NSArray *kmlLocations = [KMLLocation MR_findAllSortedBy:@"title" ascending:YES inContext:self.context];
    
    NSMutableArray *kmlViews = [NSMutableArray array];
    
    for ( KMLLocation *location in kmlLocations ) {
        BOOL showItem = [[location isVisible] boolValue];
        
        if ( showItem == YES ) {
            
            NSURL *url = [NSURL fileURLWithPath:[location locationFilePath]];
            self.kmlParser = [[KMLParser alloc] initWithURL:url];
            [self.kmlParser parseKML];
            
            // Add all of the MKOverlay objects parsed from the KML file to the map.
            NSArray *kmlAnnotations = [self.kmlParser points];
            
            [kmlViews addObject:kmlAnnotations];
        }
    }
    
    return kmlViews;
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
