//
//  MMAppDelegate.m
//  MampMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    BOOL firstRun;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.mapController];
    UINavigationBar *navBar = [navigationController navigationBar];
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];
    UIImage *backgroundImage = [UIImage imageNamed:@"header"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
   
    [self checkForFirstRun];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navigationController
                                             leftDrawerViewController:self.historyController
                                             rightDrawerViewController:nil];
    [drawerController setMaximumRightDrawerWidth:240.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:drawerController];
    [self.window makeKeyAndVisible];    
    return YES;
}

- (void)checkForFirstRun
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hasRunBefore = [defaults boolForKey:@"hasRunBefore"];
    
    if ( !hasRunBefore ) {
        [self.locationModel addMapTileCollectionWithName:@"Glasto HD map" directoryPath:@"detailed" isFlippedAxis:YES];
        [self.locationModel addMapTileCollectionWithName:@"Glasto OpenStreetMap" directoryPath:@"OpenStreetMap" isFlippedAxis:YES];
        [self.locationModel addMapTileCollectionWithName:@"EE Map" directoryPath:@"tiles" isFlippedAxis:NO];
    }
    
    [defaults setBool:YES forKey:@"hasRunBefore"];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ( [url isFileURL] ) {
        [self.locationModel addKMLLocationFromURL:url];
    }
    else
    {
        [self.locationModel addUserLocationFromURL:url];
    }
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark  - UIAlertViewDelegate
//////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        completionBlock();
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (HistoryViewController *)historyController {
    if ( !_historyController ) {
        _historyController =  [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        _historyController.locationModel = self.locationModel;
    }
    return _historyController;
}

- (MapViewController *)mapController {
    if ( !_mapController ) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        
        _mapController = (MapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MapView"];
        _mapController.locationModel = self.locationModel;
    }
    return _mapController;
}

- (LocationModel *)locationModel {
    if ( !_locationModel ) {
        _locationModel = [[LocationModel alloc] init];
    }
    return _locationModel;
}

//////////////////////////////////////////////////////////////
#pragma mark  - Application's Documents directory
//////////////////////////////////////////////////////////////

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
