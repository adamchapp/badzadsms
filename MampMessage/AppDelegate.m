//
//  MMAppDelegate.m
//  MampMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "AppDelegate.h"
#import "ECSlidingViewController.h"

@implementation AppDelegate
{
    BOOL firstRun;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setAppearance];
    
    ECSlidingViewController * drawerController = [[ECSlidingViewController alloc] init];
    [drawerController setTopViewController:[self mapNavController]];
    [drawerController setUnderLeftViewController:[self historyNavController]];
    [drawerController setAnchorRightRevealAmount:270.f];
    [drawerController setUnderLeftWidthLayout:ECFixedRevealWidth];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:drawerController];
    [self.window makeKeyAndVisible];    
    return YES;
}

- (void)setAppearance
{
    UIFont *whitney = [UIFont fontWithName:@"Whitney-Book" size:20];
    UIColor *white = [UIColor whiteColor];
    
    [[UILabel appearance] setFont:whitney];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          white,
                                                          UITextAttributeTextColor,
                                                          whitney,
                                                          UITextAttributeFont, nil]];
    [[[UIButton appearance] titleLabel] setFont:whitney];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ( [url isFileURL] ) {
        if ( [[[url lastPathComponent] pathExtension] isEqualToString:@"kml"] ) {
            [self.mapController addKMLLocationFromURL:url];
        } else if ( [[[url lastPathComponent] pathExtension] isEqualToString:@"zip"] ) {
            
            //will import files to documents directory and inform location model when done
            OverlayImportController *importController = [[OverlayImportController alloc] init];
            [importController setDelegate:self.locationModel];
            [importController addOverlayToDocumentsDirectory:url];
        }
    }
    else
    {
        [self.mapController addUserLocationFromURL:url];
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
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (UINavigationController *)mapNavController {
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.mapController];
    UINavigationBar *navBar = [navigationController navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"header"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    return navigationController;
}

- (UINavigationController *)historyNavController {
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.historyController];
    UINavigationBar *navBar = [navigationController navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"header"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    return navigationController;
}

- (HistoryViewController *)historyController {
    if ( !_historyController ) {
        _historyController =  [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
        _historyController.locationModel = self.locationModel;
        _historyController.delegate = self.mapController;
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
        _locationModel.context = self.managedObjectContext;
    }
    return _locationModel;
}

//////////////////////////////////////////////////////////////
#pragma mark  - Core Data stack
//////////////////////////////////////////////////////////////

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MapMessage" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MapMessage.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
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
