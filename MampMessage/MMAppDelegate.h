//
//  MMAppDelegate.h
//  MampMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLParser.h"
#import <MapKit/MapKit.h>
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MapViewController.h"
#import "MapItemCreator.h"
#import "HistoryViewController.h"
#import "Location+Extensions.h"
#import "Overlay+Extensions.h"
#import "Constants.h"
#import "KMLParser.h"

typedef void (^UIAlertViewBlock)(void);

@interface MMAppDelegate : UIResponder <UIApplicationDelegate>
{
    KMLParser *kmlParser;
    UIAlertViewBlock completionBlock;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSDateFormatter *formatter;

@property (strong, nonatomic) LocationModel *locationModel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
