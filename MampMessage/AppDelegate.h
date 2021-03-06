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
#import "MapViewController.h"
#import "HistoryViewController.h"
#import "UserLocation.h"
#import "KMLLocation+Extensions.h"
#import "Constants.h"
#import "KMLParser.h"

typedef void (^UIAlertViewBlock)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIAlertViewBlock completionBlock;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) HistoryViewController *historyController;
@property (strong, nonatomic) MapViewController *mapController;
@property (strong, nonatomic) LocationModel *locationModel;

- (NSURL *)applicationDocumentsDirectory;

@end
