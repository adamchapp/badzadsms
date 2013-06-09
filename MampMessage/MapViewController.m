//
//  MMRootViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) HistoryViewController *historyViewController;

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[HistoryViewController class]]) {
        
        self.historyViewController = (HistoryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HistoryView"];
        [self.historyViewController setLocationModel:self.locationModel];
        
        self.slidingViewController.underLeftViewController = self.historyViewController;
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"View did load");
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendSMS:)];
        
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 1000;
        [self.locationManager startUpdatingLocation];
    }
    
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)loadAnnotations {
    
    NSLog(@"Loading annotations");
    
    NSArray *coordinates = self.locationModel.coordinates;
    
    [self.historyViewController.tableView reloadData];
    
    if ( [coordinates count] > 0 ) {

        [self.mapView removeAnnotations:coordinates];
        
        for (BZLocation *location in coordinates) {
            BOOL showItem = [[self.locationModel.coordinateDisplayMap valueForKey:location.title] boolValue];
            if (  showItem == YES ) {
                [self.mapView addAnnotation:location];
            }
        }
        
    } else {
        NSLog(@"No annotations to add");
    }

}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
        
        NSString *urlString = [NSString stringWithFormat:@"%@ sent you a new location at %@. \n\nbadzad://badzad.com/message?lat=%@&long=%@&title=%@&timestamp=%@",name, timestamp, self.latitude.text, self.longitude.text, name, timestamp];
        
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
   
    if ( [self.locationModel.coordinates count] > 0 ) {
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in self.locationModel.coordinates)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
       // [self.mapView setVisibleMapRect:zoomRect animated:YES];
    } else {
        MKCoordinateRegion region;
        region.span = span;
        region.center = newLocation.coordinate;
        
        [self.mapView setRegion:region animated:YES];
    }
    
    self.mapView.showsUserLocation = YES;
    
    self.latitude.text =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitude.text =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (LocationModel *)locationModel {
    if ( !_locationModel ) {
        _locationModel = [[LocationModel alloc] init];
    }
    return _locationModel;
}

@end
