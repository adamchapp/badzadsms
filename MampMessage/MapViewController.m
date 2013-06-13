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

@end

@implementation MapViewController

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
    
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]]];
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateViewDataChanged object:nil];

    
    [self loadAnnotations];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupRightMenuButton{
    UIButton *buttonOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 16)];
    [buttonOverlay addTarget:self action:@selector(sendSMS:) forControlEvents:UIControlEventTouchUpInside];
    [buttonOverlay setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:buttonOverlay];
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)loadAnnotations {
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];

    [mapView setShowsUserLocation:NO];
    [mapView setShowsUserLocation:YES];

    MKMapRect zoomRect = MKMapRectNull;
    
    BOOL overlayLoaded = NO;
    
    for ( BZOverlay *bzOverlay in self.locationModel.overlays ) {
        BOOL showItem = [bzOverlay isVisible];
        
        if ( showItem == YES ) {
            
            NSURL *url = [NSURL fileURLWithPath:[bzOverlay overlayPath]];
            self.kmlParser = [[KMLParser alloc] initWithURL:url];
            [self.kmlParser parseKML];
            
            // Add all of the MKOverlay objects parsed from the KML file to the map.
            NSArray *overlays = [self.kmlParser overlays];
            NSArray *overlayAnnotations = [self.kmlParser points];
            
            [mapView addOverlays:overlays];
            [mapView addAnnotations:overlayAnnotations];
                        
            overlayLoaded = YES;

            for (id <MKOverlay> overlay in overlays) {
                zoomRect = [overlay boundingMapRect];
            }
        }
    }
    
    for (BZLocation *annotation in self.locationModel.coordinates) {
        BOOL showItem = [annotation isVisible];
        
        if (  showItem == YES ) {
            [mapView addAnnotation:annotation];
            
            //only zoom to fit annotations if there is no overlay
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    if ( overlayLoaded == NO ) {
        //now get user location and add to zoom rect (if there is no overlay)
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.locationManager.location.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
}

- (IBAction)toggleCompass:(id)sender {
    if ( [mapView userTrackingMode] == MKUserTrackingModeNone ) {
        [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    } else {
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
}

- (IBAction)toggleViewMode:(id)sender {
    
    if ( [mapView mapType] == MKMapTypeStandard ) {
        [mapView setMapType:MKMapTypeHybrid];
        [satelliteButton setBackgroundImage:[UIImage imageNamed:@"SatelliteSelected"] forState:UIControlStateNormal];
        [self toggleAnnotationLabelColors:YES];
    } else if ( [mapView mapType] == MKMapTypeHybrid ) {
        [mapView setMapType:MKMapTypeStandard];
        [satelliteButton setBackgroundImage:[UIImage imageNamed:@"SatelliteUnselected"] forState:UIControlStateNormal];
        [self toggleAnnotationLabelColors:NO];
    }
}

- (void)toggleAnnotationLabelColors:(BOOL)isWhite
{
    for (id<MKAnnotation> annotation in mapView.annotations){
        CustomAnnotationView* view = (CustomAnnotationView *)[mapView viewForAnnotation:annotation];
        if (view){

            UIColor *textColor = (isWhite == YES) ? [UIColor whiteColor] : [UIColor blackColor];
            [view.annotationLabel setTextColor:textColor];
        }
    }
}

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if ( mode == MKUserTrackingModeNone ) {
        [compassButton setBackgroundImage:[UIImage imageNamed:@"CompassUnselected"] forState:UIControlStateNormal];
    } else {
        [compassButton setBackgroundImage:[UIImage imageNamed:@"CompassSelected"] forState:UIControlStateNormal];
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
        [formatter setDateFormat:BZDateFormat];
        
        NSString *timestamp = [formatter stringFromDate:date];
        
        NSArray *names = [self newNamesFromDeviceName:[[UIDevice currentDevice] name]];
        
        NSString *name = [names objectAtIndex:0];
        
        NSString *urlString = [NSString stringWithFormat:@"%@ sent you a new location at %@. \n\nbadzad://mapmessage.com/message?lat=%@&long=%@&title=%@&timestamp=%@",name, timestamp, self.latitude, self.longitude, name, timestamp];
        
        controller.body = urlString;
        
        [self presentViewController:controller animated:YES completion:nil];
        
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
#pragma mark  - MKMapViewDelegate methods
//////////////////////////////////////////////////////////////


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [self.kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //Don't trample the user location annotation (pulsing blue dot).
        return nil;
    } else if ( [annotation isKindOfClass:[BZLocation class]]) {
        return nil;
    }
    
    static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";
    
    CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
    
    if (annotationView == nil)
    {
        annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
    }
        
    [annotationView.annotationLabel setText:[annotation title]];
    
    return annotationView;
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
//    MKCoordinateRegion region;
//    region.span = span;
//    region.center = newLocation.coordinate;
//    
//    [mapView setRegion:region animated:YES];
    
    mapView.showsUserLocation = YES;
    
    self.latitude =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitude =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
}

@end
