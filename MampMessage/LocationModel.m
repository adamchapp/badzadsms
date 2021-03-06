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
    Location *previousLocation = [self getUserLocationByName:title];
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

- (UserLocation *)addUserLocationWithTitle:(NSString *)title
                          sender:(NSString *)sender
                       timestamp:(NSDate *)timestamp
                        latitude:(double)latitude
                       longitude:(double)longitude
                       selected:(BOOL)selected
{
    NSDateFormatter *readableFormatter = [[NSDateFormatter alloc] init];
    [readableFormatter setDateFormat:BZReadableDateFormat];
    
    UserLocation *previousLocation = [self getUserLocationByName:title];
    UserLocation *newLocation;
    
    if ( previousLocation ) {
        newLocation = previousLocation;
    } else {
        newLocation = [NSEntityDescription
                       insertNewObjectForEntityForName:@"UserLocation"
                       inManagedObjectContext:self.context];
    }
    
    newLocation.sender = sender;
    newLocation.title = title;
    newLocation.subtitle = [readableFormatter stringFromDate:timestamp];
    newLocation.timestamp = timestamp;
    newLocation.latitude = [NSNumber numberWithDouble:latitude];
    newLocation.longitude = [NSNumber numberWithDouble:longitude];
    newLocation.selected = [NSNumber numberWithBool:YES];
    
    [self saveContext];
    
    return newLocation;
}

- (void)removeUserLocation:(UserLocation *)location
{
    [self.context deleteObject:location];
    [self saveContext];
}

- (void)setUserLocationAsSelected:(UserLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:YES]];
    [self saveContext];
}

- (void)setUserLocationAsDeselected:(UserLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:NO]];
    [self saveContext];
}

- (UserLocation *)getUserLocationByName:(NSString *)name
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserLocation" inManagedObjectContext:self.context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title == %@", name];
    [request setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedObjects = [self.context executeFetchRequest:request error:&error];
    return [fetchedObjects lastObject];
}

- (void)setDestination:(Location *)destination
{
    if ( self.currentDestination != nil ) {
        NSLog(@"[LM] unsetting previous destination");
        [self.currentDestination setSelected:[NSNumber numberWithBool:NO]];
        NSLog(@"[LM] phew");
    }
    
    NSLog(@"[LM] done.");
    
    if ( destination ) {
        NSLog(@"[LM] Setting destination");
        [destination setSelected:[NSNumber numberWithBool:YES]];
    } else {
        NSLog(@"[LM] setting destination to nil");
    }

    NSLog(@"[LM] done.");
    
    self.currentDestination = destination;
    
    [self saveContext];
}

//////////////////////////////////////////////////////////////
#pragma mark  - KML Locations
//////////////////////////////////////////////////////////////

- (void)addKMLLocations:(NSArray *)annotations
{
    for ( id<MKAnnotation>annotation in annotations ) {
        
        KMLLocation *location;
        KMLLocation *previousLocation = [self getKMLLocationByName:annotation.title];
        
        if ( previousLocation ) {
            location = previousLocation;
        } else {
            location = [NSEntityDescription
                        insertNewObjectForEntityForName:@"KMLLocation"
                        inManagedObjectContext:self.context];
        }
        
        location.title = annotation.title;
        location.subtitle = annotation.subtitle;
        location.latitude = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        location.longitude = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        location.selected = [NSNumber numberWithBool:NO];
    }
    
    [self saveContext];
}

- (void)removeKMLLocation:(KMLLocation *)location
{
    [self.context deleteObject:location];
    [self saveContext];
}

- (void)setKMLLocationAsSelected:(KMLLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:YES]];
    [self saveContext];
}

- (void)setKMLLocationAsDeselected:(KMLLocation *)location
{
    [location setSelected:[NSNumber numberWithBool:NO]];
    [self saveContext];
}

- (KMLLocation *)getKMLLocationByName:(NSString *)name
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KMLLocation" inManagedObjectContext:self.context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title == %@", name];
    [request setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedObjects = [self.context executeFetchRequest:request error:&error];
    return [fetchedObjects lastObject];
}

//////////////////////////////////////////////////////////////
#pragma mark  - MapTile Collections
//////////////////////////////////////////////////////////////

- (void)addMapTileCollectionWithName:(NSString *)name directoryPath:(NSString *)path isFlippedAxis:(BOOL)flipped
{
    MapTileCollection *collection = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"MapTileCollection"
                                     inManagedObjectContext:self.context];
    collection.title = name;
    collection.directoryPath = path;
    collection.isVisible = [NSNumber numberWithBool:NO];
    collection.isFlippedAxis = [NSNumber numberWithBool:flipped];
        
    [self saveContext];
}

- (void)removeMapTileCollection:(MapTileCollection *)location
{
    [self.context deleteObject:location];
    
    [self saveContext];
}

- (void)showMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [self saveContext];
}

- (void)hideMapTileCollection:(MapTileCollection *)location
{
    [location setIsVisible:[NSNumber numberWithBool:NO]];
    [self saveContext];
}

- (void)saveContext {
    if ( [self.context hasChanges] ) {
        NSError *error;
        if (![self.context save:&error] ) {
            NSLog(@"[LM] There was an error saving %@", error.description);
        } else {
            NSLog(@"[LM] Context saved without error");
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (NSArray *)userLocations {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserLocation" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSArray *)kmlLocations {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"KMLLocation" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;}

- (NSArray *)mapTileCollections {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MapTileCollection" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSArray *)mapTileCollectionViews {
    
    NSMutableArray *collectionViews = [NSMutableArray arrayWithCapacity:[[self mapTileCollections] count]];
    
    for ( MapTileCollection *collection in self.mapTileCollections ) {
        if ( [collection.isVisible boolValue] ) {
            NSString *tileDirectory = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:collection.directoryPath];
            
            NSLog(@"using tiledirectory %@", tileDirectory);
            
            MapOverlay *overlay = [[MapOverlay alloc] initWithDirectory:tileDirectory shouldFlipOrigin:[collection.isFlippedAxis boolValue]];
            
            [collectionViews addObject:overlay];
        }
    }
    
    return collectionViews;
}

- (MapOverlay *)mapOverlayForMapTileCollection:(MapTileCollection *)collection
{
    NSString *tileDirectory = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:collection.directoryPath];
    
    MapOverlay *overlay = [[MapOverlay alloc] initWithDirectory:tileDirectory shouldFlipOrigin:[collection.isFlippedAxis boolValue]];
    
    return overlay;
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

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

// Returns the URL to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory
{
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documentsPaths objectAtIndex:0];
}

@end
