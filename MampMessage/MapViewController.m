//
//  MMRootViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MapViewController.h"
#import "BZLocation.h"
#import "UIViewController+MMDrawerController.h"
#import "Constants.h"

@interface MapViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

bool isCompassOn = NO;
bool is3dOn = NO;

@synthesize locationManager = _locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        [self.locationManager startUpdatingLocation];
    }
    
    self.navigationItem.title = @"Bad Zad!";
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateViewDataChanged object:nil];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupRightMenuButton{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSMS:)];
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)loadAnnotations {
    
    [self.mapView removeAnnotations:self.mapView.annotations];

    NSArray *coordinates = self.locationModel.coordinates;

    [self.mapView setShowsUserLocation:NO];
    [self.mapView setShowsUserLocation:YES];
        
    for (BZLocation *location in coordinates) {
        NSString *key = [self.locationModel makeKeyFromLocation:location];
        BOOL showItem = [[self.locationModel.coordinateDisplayMap valueForKey:key] boolValue];
        if (  showItem == YES ) {
            [self.mapView addAnnotation:location];
        }
    }
    
    //now update zoom rect
    MKMapRect zoomRect = MKMapRectNull;
    for (BZLocation* annotation in self.locationModel.coordinates)
    {
        NSString *key = [self.locationModel makeKeyFromLocation:annotation];
        BOOL showCoordinate = [[self.locationModel.coordinateDisplayMap valueForKey:key] boolValue];
        if ( showCoordinate == YES ) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);                
        }
    }
    
    //now get user location and add to zoom rect
    MKMapPoint annotationPoint = MKMapPointForCoordinate(self.locationManager.location.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    zoomRect = MKMapRectUnion(zoomRect, pointRect);
            
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
}

- (IBAction)toggleCompass:(id)sender {
    isCompassOn = !isCompassOn;
    
    MKUserTrackingMode mode = [self.mapView userTrackingMode];
    
    if ( mode == MKUserTrackingModeNone ) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    } else {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendSMS:(id)sender
{
    if ( [MFMessageComposeViewController canSendText] ) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        NSString *timestamp = [formatter stringFromDate:date];
        
        NSArray *names = [self newNamesFromDeviceName:[[UIDevice currentDevice] name]];
        
        NSString *name = [names objectAtIndex:0];
        
        NSString *urlString = [NSString stringWithFormat:@"%@ sent you a new location at %@. \n\nbadzad://badzad.com/message?lat=%@&long=%@&title=%@&timestamp=%@",name, timestamp, self.latitude, self.longitude, name, timestamp];
        
        controller.body = urlString;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        NSLog(@"Cannot send SMS from this device");
    }
}

- (NSArray*) newNamesFromDeviceName: (NSString *) deviceName
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@" '’\\"];
    NSArray* words = [deviceName componentsSeparatedByCharactersInSet:characterSet];
    NSMutableArray* names = [[NSMutableArray alloc] init];
    
    bool foundShortWord = false;
    for (NSString __strong *word in words)
    {
        if ([word length] <= 2)
            foundShortWord = true;
        if ([word compare:@"iPhone"] != 0 && [word compare:@"iPod"] != 0 && [word compare:@"iPad"] != 0 && [word length] > 2)
        {
            word = [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[word substringToIndex:1] uppercaseString]];
            [names addObject:word];
        }
    }
    if (!foundShortWord && [names count] > 1)
    {
        int lastNameIndex = [names count] - 1;
        NSString* name = [names objectAtIndex:lastNameIndex];
        unichar lastChar = [name characterAtIndex:[name length] - 1];
        if (lastChar == 's')
        {
            [names replaceObjectAtIndex:lastNameIndex withObject:[name substringToIndex:[name length] - 1]];
        }
    }
    return names;
}

//////////////////////////////////////////////////////////////
#pragma mark  - MFMessageComposeViewControllerDelegate methods
//////////////////////////////////////////////////////////////

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alertView;
    
    switch (result) {
        case MessageComposeResultSent:
            alertView = [[UIAlertView alloc] initWithTitle:@"Message sent" message:@"Your updated location has been sent" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            break;
            
        case MessageComposeResultFailed:
            alertView = [[UIAlertView alloc] initWithTitle:@"Message sending failed" message:@"Your updated location could not been sent" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            break;
            
        default:
            break;
    }
    
    [alertView show];
}

//////////////////////////////////////////////////////////////
#pragma mark  - CLLocationManagerDelegate methods
//////////////////////////////////////////////////////////////

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Location manager update");
    
    double miles = 12.0;
    double scalingFactor =
    ABS( cos(2 * M_PI * newLocation.coordinate.latitude /360.0) );
    
    MKCoordinateSpan span;
    span.latitudeDelta = miles/69.0;
    span.longitudeDelta = miles/( scalingFactor*69.0 );

    //update view rect
    MKCoordinateRegion region;
    region.span = span;
    region.center = newLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
    
    self.mapView.showsUserLocation = YES;
    
    self.latitude =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitude =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
}

@end
