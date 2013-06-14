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
    
    NSDateFormatter *readableFormatter = [[NSDateFormatter alloc] init];
    [readableFormatter setDateFormat:BZReadableDateFormat];
    
    NSString *title = [self.urlParser valueForVariable:@"title"];
    NSString *timeStampString = [self.urlParser valueForVariable:@"timestamp"];
    
    NSDate *timestamp = [self.formatter dateFromString:timeStampString];
    
    double latitude = [[self.urlParser valueForVariable:@"lat"] doubleValue];
    double longitude = [[self.urlParser valueForVariable:@"long"] doubleValue];
    
    UserLocation *location = [UserLocation MR_createInContext:self.context];
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
#pragma mark  - BZ Overlays
//////////////////////////////////////////////////////////////

- (void)addKMLLocationFromURL:(NSURL *)url
{
    
    NSString *filenameWithExtension = [url lastPathComponent];
    NSString *filename = [filenameWithExtension stringByDeletingPathExtension];
        
    KMLLocation *location = [KMLLocation MR_createInContext:self.context];
    location.title = filename;
    location.overlayPath = url.path;
    location.isVisible = [NSNumber numberWithBool:YES];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"overlay was created in persistent store");
        }
        else {
            NSLog(@"overlay was not created");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)removeKMLAnnotation:(KMLLocation *)location
{
    [location MR_deleteInContext:self.context];
    
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"overlay was deleted from persistent store");
        }
        else {
            NSLog(@"overlay was not deleted");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateDataChanged object:nil];
}

- (void)showKMLLocation:(KMLLocation *)location
{
    [location setIsVisible:[NSNumber numberWithBool:YES]];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"overlay show/hide was updated in persistent store (to show)");
        }
        else {
            NSLog(@"overlay show/hide was not updated");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BZCoordinateViewDataChanged object:nil];
}

- (void)hideKMLLocation:(KMLLocation *)location
{
    [location setIsVisible:NO];
    [self.context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if ( success ) {
            NSLog(@"overlay show/hide was updated in persistent store (to hide)");
        }
        else {
            NSLog(@"overlay show/hide was not updated");
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
