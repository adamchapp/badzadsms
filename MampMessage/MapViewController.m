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
   
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [mapView addGestureRecognizer:longPress];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateViewDataChanged object:nil];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.delegate = self;
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Set the starting game location.
    CLLocationCoordinate2D startingLocation;
    startingLocation.latitude = 51.154047246473084;
    startingLocation.longitude =-2.5871944427490234;
    
    mapView.region = MKCoordinateRegionMakeWithDistance(startingLocation, 10000, 10000);
    [mapView setCenterCoordinate:startingLocation];
    
    [self loadAnnotations];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma mark  - Drawing methods
//////////////////////////////////////////////////////////////

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

- (void)loadAnnotations {
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];

    for ( MapTileCollection *collection in self.locationModel.mapTileCollections ) {
        BOOL showItem = [collection.isVisible boolValue];
        
        if ( showItem ) {
            NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:collection.directoryPath];

            MapOverlay *overlay = [[MapOverlay alloc] initWithDirectory:tileDirectory];
            [mapView addOverlay:overlay];
        }
    }
    
    MKMapRect zoomRect = MKMapRectNull;
    
    //            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
    //            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    //            zoomRect = MKMapRectUnion(zoomRect, pointRect);
    
    //load kml overlay
    BOOL overlayLoaded = NO;
    
    for ( KMLLocation *location in self.locationModel.kmlLocations ) {
        BOOL showItem = [[location isVisible] boolValue];
        
        if ( showItem == YES ) {
            
            NSURL *url = [NSURL fileURLWithPath:[location locationFilePath]];
            self.kmlParser = [[KMLParser alloc] initWithURL:url];
            [self.kmlParser parseKML];
            
            // Add all of the MKOverlay objects parsed from the KML file to the map.
            NSArray *overlayAnnotations = [self.kmlParser points];
            
            [mapView addAnnotations:overlayAnnotations];
                        
            overlayLoaded = YES;
        }
    }
    
    //load user annotations
    for (UserLocation *location in self.locationModel.userLocations) {
        BOOL showItem = [[location isVisible] boolValue];
        
        if (  showItem == YES ) {
            [mapView addAnnotation:location];
            
            //only zoom to fit annotations if there is no overlay
            MKMapPoint annotationPoint = MKMapPointForCoordinate(location.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
//
//    if ( overlayLoaded == NO ) {
//        //now get user location and add to zoom rect (if there is no overlay)
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.locationManager.location.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//        zoomRect = MKMapRectUnion(zoomRect, pointRect);
//    }
    
//    [mapView setVisibleMapRect:zoomRect animated:NO];//edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
}


- (void)setAnnotationLabelColors:(BOOL)isWhite
{
    for (id<MKAnnotation> annotation in mapView.annotations){
        
        if ( ![annotation isKindOfClass:[MKUserLocation class]]) {
            
            CustomAnnotationView* view = (CustomAnnotationView *)[mapView viewForAnnotation:annotation];
            if (view){
                
                UIColor *textColor = (isWhite == YES) ? [UIColor whiteColor] : [UIColor blackColor];
                [view.annotationLabel setTextColor:textColor];
            }
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - User actions
//////////////////////////////////////////////////////////////

-(void)mapLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan)
        return;

    // Get the screen coordinates for the touch relative
    // to our map view.
    CGPoint point = [gesture locationInView:mapView];
    // Get the world coordinates that corresponds to
    // the screen coordinates.
    CLLocationCoordinate2D coordinates = [mapView
                                          convertPoint:point
                                          toCoordinateFromView:mapView];
    
    // Create and add an annotation with the coordinates.
    [self.locationModel addUserLocationWithTitle:@"Dropped pin" timestamp:[NSDate date] latitude:coordinates.latitude longitude:coordinates.longitude isVisible:YES];
    
//    [self.navigationItem setLeftBarButtonItem:nil];
//    [self.navigationItem.rightBarButtonItem setCustomView:[[UIView alloc] init]];
//    
//    NSInteger pin_width = 29;
//    NSInteger pin_height = 40;
//    
//    // Get the screen coordinates for the touch relative
//    // to our map view.
//    CGPoint point = [gesture locationInView:mapView];
//    point.y -= pin_height/2;
//    
//    self.dropPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-pin"]];
//    [self.dropPin setFrame:CGRectMake(0, 0, pin_width, pin_height)];
//    [self.dropPin setCenter:point];
//        
//    [mapView addSubview:self.dropPin];
//    
//    NSLog(@"Dropping pins at %f / %f", point.x, point.y);
//    
//    self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-with-text"]];
//    
//    self.cancelButton = [[UIButton alloc] init];
//    [self.cancelButton setFrame:CGRectMake(244, 10, 24, 24)];
//    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel-button"] forState:UIControlStateNormal];
//    [self.cancelButton addTarget:self action:@selector(cancelSelection) forControlEvents:UIControlEventAllEvents];
//    
//    self.okButton = [[UIButton alloc] init];
//    [self.okButton setFrame:CGRectMake(276, 10, 24, 24)];
//    [self.okButton setBackgroundImage:[UIImage imageNamed:@"ok-button"] forState:UIControlStateNormal];
//    [self.okButton addTarget:self action:@selector(confirmSelection) forControlEvents:UIControlEventAllEvents];
//    
//    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(26, 7, 214, 30)];
//    [self.textField setOpaque:NO];
//    [self.textField setPlaceholder:@"Enter a name for your pin"];
//    [self.textField setBorderStyle:UITextBorderStyleNone];
//    [self.textField setFont:[UIFont fontWithName:@"Whitney-Light" size:13]];
//    [self.textField setDelegate:self];
//    
//    [mapView addSubview:self.headerBackground];
//    [mapView addSubview:self.textField];
//    [mapView addSubview:self.cancelButton];
//    [mapView addSubview:self.okButton];
}

- (void)cancelSelection {
    NSLog(@"cancelled");
    [self removePinView];
}

- (void)confirmSelection {
    NSLog(@"Adding new pin at pin view coordinate %f %f", self.dropPin.frame.origin.x, self.dropPin.frame.origin.y );
    
    CGPoint point = self.dropPin.bounds.origin;
    
    CLLocationCoordinate2D coordinates = [mapView
                                          convertPoint:point
                                          toCoordinateFromView:mapView];
    
    
    NSLog(@"Coordinates are %f %f", coordinates.latitude, coordinates.longitude);
    
    [self.locationModel addUserLocationWithTitle:self.textField.text timestamp:[NSDate date] latitude:coordinates.latitude longitude:coordinates.longitude isVisible:YES];
        
    [self removePinView];
}

- (void)removePinView {
    
    [self.cancelButton removeTarget:self action:@selector(cancelSelection) forControlEvents:UIControlEventAllEvents];
    [self.okButton removeTarget:self action:@selector(confirmSelection) forControlEvents:UIControlEventAllEvents];
    
    [self.textField removeFromSuperview];
    [self.headerBackground removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self.okButton removeFromSuperview];
    [self.dropPin removeFromSuperview];
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
        [self setAnnotationLabelColors:YES];
    } else if ( [mapView mapType] == MKMapTypeHybrid ) {
        [mapView setMapType:MKMapTypeStandard];
        [satelliteButton setBackgroundImage:[UIImage imageNamed:@"SatelliteUnselected"] forState:UIControlStateNormal];
        [self setAnnotationLabelColors:NO];
    }
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
    MapOverlayView *view = [[MapOverlayView alloc] initWithOverlay:overlay];
    view.overlayAlpha = 1.0;
    return view;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //Don't trample the user location annotation (pulsing blue dot).
        return nil;
    }
   
    static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";
    
    CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
    
    if (annotationView == nil)
    {
        annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
    }
    
    if ( [annotation isKindOfClass:[UserLocation class]]) {
        [annotationView setImage:[UIImage imageNamed:@"annotation-view-user"]];
    }
    
    [annotationView.annotationLabel setText:[annotation title]];
    
    return annotationView;
}


-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if ( mode == MKUserTrackingModeNone ) {
        [compassButton setBackgroundImage:[UIImage imageNamed:@"CompassUnselected"] forState:UIControlStateNormal];
    } else {
        [compassButton setBackgroundImage:[UIImage imageNamed:@"CompassSelected"] forState:UIControlStateNormal];
    }
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

//////////////////////////////////////////////////////////////
#pragma mark  - UITextFieldDelegate methods
//////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)hideKeyboard:(id)sender
{
    NSLog(@"running hide keyboard");
    [self.textField endEditing:NO];
}

@end
