//
//  MMRootViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#define CLCOORDINATES_EQUAL( coord1, coord2 ) ((coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude))

#import "MapViewController.h"


@interface MapViewController ()
{
    NSInteger pin_width;
    NSInteger pin_height;
}

@property (strong, nonatomic) UIButton *leftDrawerButtonItem;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UIButton *saveAnnotationButton;
@property (nonatomic, strong) UIButton *cancelAnnotationButton;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) URLParser *urlParser;
@property (nonatomic, strong) KMLParser *kmlParser;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

@synthesize locationManager = _locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pin_width = 33;
    pin_height = 44;
    
    [self.navigationController setTitle:@"Back"];
    
    [self createMenuButtons];
    [self addGestureRecognisers];
    [self setupLocationManager];
    [self loadAnnotations];
    
    [self setEditing:NO];
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    _pinViewHeader = nil;
    _smsController = nil;
    _formatter = nil;
    
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Startup methods
//////////////////////////////////////////////////////////////

- (void)createMenuButtons{
    self.leftDrawerButtonItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 15)];
    [self.leftDrawerButtonItem setBackgroundImage:[UIImage imageNamed:@"SidebarButton"] forState:UIControlStateNormal];
    [self.leftDrawerButtonItem addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.plusButton = [[UIButton alloc] initWithFrame:CGRectMake(40, -10, 35, 32)];
    [self.plusButton addTarget:self action:@selector(handleSMSButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.plusButton setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];

    self.cancelAnnotationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 13)];
    [self.cancelAnnotationButton addTarget:self action:@selector(removeNewAnnotationView) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelAnnotationButton setBackgroundImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    
    self.saveAnnotationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 13)];
    [self.saveAnnotationButton addTarget:self action:@selector(addAnnotation) forControlEvents:UIControlEventTouchUpInside];
    [self.saveAnnotationButton setBackgroundImage:[UIImage imageNamed:@"Save"] forState:UIControlStateNormal];
}

- (void)addGestureRecognisers
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showNewAnnotationView:)];
    longPress.minimumPressDuration = 0.7;
    [mapView addGestureRecognizer:longPress];
}

- (void)setupLocationManager
{
    [PSLocationManager sharedLocationManager].delegate = self;
    [[PSLocationManager sharedLocationManager] prepLocationUpdates];
    [[PSLocationManager sharedLocationManager] startLocationUpdates];
}

- (void)loadAnnotations {
    
    [mapView addAnnotations:self.locationModel.kmlLocations];
    [mapView addAnnotations:self.locationModel.userLocations];
    
    for ( UserLocation *location in self.locationModel.userLocations ) {
        if ( [location.selected boolValue] == YES) {
            NSLog(@"[MVC] %@ is current destination at startup", location.title);
            [self setDestination:location];
        }
    }

    for ( KMLLocation *location in self.locationModel.kmlLocations ) {
        if ( [location.selected boolValue] == YES) {
            NSLog(@"[MVC] %@ is current destination at startup", location.title);
            [self setDestination:location];
        }
    }
    
    [mapView addOverlays:self.locationModel.mapTileCollectionViews];

    [mapView setShowsUserLocation:YES];
}

- (void)zoomMap {
    
    NSLog(@"[MVC] Zoom map");
    
    MKMapRect zoomRect = MKMapRectNull;
    
    //create zoom rect from user location
    if ( self.latitude != 0.000 & self.longitude != 0.000 ) {
        NSLog(@"[MVC] Have user location %.4f/%.4f", self.latitude, self.longitude);
        MKMapPoint userLocation = MKMapPointForCoordinate(CLLocationCoordinate2DMake(self.latitude, self.longitude));
        zoomRect = MKMapRectMake(userLocation.x, userLocation.y, 0.1, 0.1);
    } else {
        NSLog(@"[MVC] Don't have user location");
    }
    
    if ( self.locationModel.currentDestination ) {
        NSLog(@"[MVC] Have current destination %.4f/%.4f", self.locationModel.currentDestination.coordinate.latitude, self.locationModel.currentDestination.coordinate.longitude);
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.locationModel.currentDestination.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
        
        [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(25, 25, 25, 25) animated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - AnnotationDelegate methods
//////////////////////////////////////////////////////////////

- (void)showAlertView:(NSString *)locationTitle
{
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to replace the current location for %@ with an older one?", locationTitle];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setDelegate:self];
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        self.confirmBlock();
    }
}

- (void)addUserLocationFromURL:(NSURL *)url
{
    NSLog(@"[LM] Adding new user location from URL");
    self.urlParser = [[URLParser alloc] initWithURLString:url.absoluteString];
    
    NSString *title = [[self.urlParser valueForVariable:@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSString *timeStampString = [self.urlParser valueForVariable:@"timestamp"];
    NSString *sender = [self.urlParser valueForVariable:@"sender"];
    
    NSDate *timestamp = [self.formatter dateFromString:timeStampString];
    
    double latitude = [[self.urlParser valueForVariable:@"lat"] doubleValue];
    double longitude = [[self.urlParser valueForVariable:@"long"] doubleValue];
    
    //var that = this;
    __weak typeof(self) weakSelf = self;
    __weak typeof(MKMapView) *weakMap = mapView;
    
    self.confirmBlock = ^ {
        UserLocation *location = [weakSelf.locationModel addUserLocationWithTitle:title sender:sender timestamp:timestamp latitude:latitude longitude:longitude selected:YES];
        [weakSelf setDestination:location];
        [weakMap addAnnotation:(id)location];
    };
    
    if ( [weakSelf.locationModel isLocationValid:title timestamp:timestamp] ) {
        self.confirmBlock();
    } else {
        [self showAlertView:title];
    }
}

- (void)addKMLLocationFromURL:(NSURL *)url
{
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *kmlAnnotations = [self.kmlParser points];
    
    [self.locationModel addKMLLocations:kmlAnnotations];
    [mapView addAnnotations:kmlAnnotations];
}

- (void)deleteSelectedAnnotation:(id<MKAnnotation>)annotation
{
    [mapView removeAnnotation:annotation];
    
    Location *location = (Location *)annotation;
    
    if ( [location.selected boolValue] == YES ) {
        NSLog(@"[MVC] this item was selected in the model, unset before delete");
        [self.locationModel setDestination:nil];
    }
    
    if ( [annotation isKindOfClass:[UserLocation class]] ) {
        [self.locationModel removeUserLocation:(UserLocation *)annotation];        
    } else if ( [annotation isKindOfClass:[KMLLocation class]] ) {
        [self.locationModel removeKMLLocation:(KMLLocation *)annotation];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setDestination:(Location *)location {
    
    [self.locationModel setDestination:location];
    
    NSLog(@"[MVC] setDestination: Unselecting all items");
    for (id<MKAnnotation> myAnnot in self.locationModel.userLocations){
        AnnotationView* view = (AnnotationView *)[mapView viewForAnnotation:myAnnot];
        view.image = [UIImage imageNamed:@"annotation-view-unselected"];
        [view setSelected:NO animated:NO];
    }
    
    for (id<MKAnnotation> myAnnot in self.locationModel.kmlLocations){
        KMLAnnotationView* view = (KMLAnnotationView *)[mapView viewForAnnotation:myAnnot];
        view.image = [UIImage imageNamed:@"annotation-view-kml"];
        [view setSelected:NO animated:NO];
    }
    
    if ( location ) {
        NSLog(@"[MVC] setDestination: Selecting new item");
        id <MKAnnotation>annotation = (id <MKAnnotation>)location;
        MKAnnotationView *annotationView = [mapView viewForAnnotation:annotation];
        [annotationView setImage:[UIImage imageNamed:@"annotation-view-destination"]];
    }
    
    [self zoomMap];
}

-(void)showMapTileCollection:(MapTileCollection *)collection {
    
    MapOverlay *overlay = [self.locationModel mapOverlayForMapTileCollection:collection];
    [mapView addOverlay:overlay];
    [self.locationModel showMapTileCollection:collection];
}

-(void)hideMapTileCollection:(MapTileCollection *)collection {
    
    //iterate through mapView overlays, comparing the basedirectory with collection's directoryPath
    for ( MKOverlayView *overlayView in mapView.overlays ) {
        
        NSString *overlayDirectoryName = [[overlayView valueForKey:@"baseDirectory"] lastPathComponent];
        
        if ( [overlayDirectoryName isEqualToString:collection.directoryPath] ) {
            [mapView removeOverlay:(id)overlayView];
        }
    }
    [self.locationModel hideMapTileCollection:collection];
}

//////////////////////////////////////////////////////////////
#pragma mark  - User actions
//////////////////////////////////////////////////////////////

-(void)showNewAnnotationView:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan || self.isEditing )
        return;
   
    [self setEditing:YES];
    
    // Get the screen coordinates for the touch relative
    // to our map view.
    CGPoint point = [gesture locationInView:mapView];
    point.y -= pin_height/2;
    
    self.dropPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation-view-selected"]];
    [self.dropPin setFrame:CGRectMake(0, 0, pin_width, pin_height)];
    [self.dropPin setCenter:point];
    
    [self.view addGestureRecognizer:self.pinViewHeader.gestureRecognizer];
    
    [mapView addSubview:self.dropPin];
    [mapView addSubview:self.pinViewHeader];
    
    CGRect pinFrame = self.pinViewHeader.frame;
    
    //move the header off screen
    [self.pinViewHeader setFrame:CGRectMake(0, -pinFrame.size.height, pinFrame.size.width, pinFrame.size.height)];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        [self.pinViewHeader setFrame:CGRectMake(0, 0, pinFrame.size.width, pinFrame.size.height)];

                     }
                     completion:nil];
}

- (void)handleAnnotationTitleEntered:(NSNotification *)notification {
    UITextField *textField = (UITextField *)[notification object];
    
    BOOL enableSaveButton = ( [textField.text length] > 0 ) ? YES : NO;
    [[self.navigationItem rightBarButtonItem] setEnabled:enableSaveButton];
}

- (void)removeNewAnnotationView {
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if ( [recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ) {
            [mapView removeGestureRecognizer:recognizer];
        }
    }

    [self.view removeGestureRecognizer:self.pinViewHeader.gestureRecognizer];

    CGRect pinFrame = self.pinViewHeader.frame;

    [self.pinViewHeader.textField setText:@""];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.pinViewHeader setFrame:CGRectMake(0, -pinFrame.size.height, pinFrame.size.width, pinFrame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self.pinViewHeader removeFromSuperview];
                     }];

    [self.dropPin removeFromSuperview];
    
    [self setEditing:NO];
}

- (void)addAnnotation {
    
    CGPoint point = self.dropPin.center;
    point.y += pin_height/2;
    
    CLLocationCoordinate2D coordinates = [mapView
                                          convertPoint:point
                                          toCoordinateFromView:mapView];
    
    UserLocation *location = [self.locationModel addUserLocationWithTitle:self.pinViewHeader.textField.text
                                                                   sender:[DeviceNameUtil nameFromDevice]
                                                                timestamp:[NSDate date]
                                                                 latitude:coordinates.latitude
                                                                longitude:coordinates.longitude
                                                                 selected:YES];
    [mapView addAnnotation:(id)location];
    
    NSLog(@"[MVC] Calling set destination");
    [self setDestination:location];
    [self removeNewAnnotationView];
}

- (IBAction)handleSMSButtonClicked:(id)sender
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BZDateFormat];
    
    NSString *timestamp = [formatter stringFromDate:date];
    NSString *name = [DeviceNameUtil nameFromDevice];
    
    [self sendSMSNamed:name timestamp:timestamp latitude:self.latitude longitude:self.longitude];
}

- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude
{
    [self.smsController sendSMSNamed:title timestamp:timestamp latitude:latitude longitude:longitude];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)toggleCompass:(id)sender {
    if ( [mapView userTrackingMode] == MKUserTrackingModeNone ) {
        [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    } else {
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
}

- (void)hideKeyboard:(id)sender {
    [self.pinViewHeader hideKeyboard:sender];
}

- (void)toggleMenuItems:(BOOL)isEditing
{
    if ( isEditing ) {
        UIBarButtonItem *editingLeftButton = [[UIBarButtonItem alloc] initWithCustomView:self.cancelAnnotationButton];
        UIBarButtonItem *editingRightButton = [[UIBarButtonItem alloc] initWithCustomView:self.saveAnnotationButton];
        
        [self.navigationItem setLeftBarButtonItem:editingLeftButton animated:YES];
        [self.navigationItem setRightBarButtonItem:editingRightButton animated:YES];
        
        //set disabled by default
        [[self.navigationItem rightBarButtonItem] setEnabled:NO];
        
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Add_a_Pin"]]];
    } else {
        UIBarButtonItem *standardRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.plusButton];
        UIBarButtonItem *standardLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftDrawerButtonItem];
        
        [self.navigationItem setLeftBarButtonItem:standardLeftBarButtonItem animated:NO];
        [self.navigationItem setRightBarButtonItem:standardRightBarButtonItem animated:NO];
        
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]]];
    }
}

- (IBAction)toggleViewMode:(id)sender {
    
    if ( [mapView mapType] == MKMapTypeStandard ) {
        [mapView setMapType:MKMapTypeHybrid];
        [satelliteButton setBackgroundImage:[UIImage imageNamed:@"SatelliteSelected"] forState:UIControlStateNormal];
    } else if ( [mapView mapType] == MKMapTypeHybrid ) {
        [mapView setMapType:MKMapTypeStandard];
        [satelliteButton setBackgroundImage:[UIImage imageNamed:@"SatelliteUnselected"] forState:UIControlStateNormal];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - Overriden methods
//////////////////////////////////////////////////////////////

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if ( editing ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAnnotationTitleEntered:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidChangeNotification
                                                      object:nil];
    }
    
    [self toggleMenuItems:editing];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

- (PinViewHeader *)pinViewHeader {
    if ( !_pinViewHeader ) {
        _pinViewHeader = [[PinViewHeader alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    }
    return _pinViewHeader;
}

- (SMSController *)smsController {
    if ( !_smsController ) {
        _smsController = [[SMSController alloc] initWithRootViewController:self];
    }
    return _smsController;
}

- (NSDateFormatter *)formatter {
    if ( !_formatter ) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:BZDateFormat];
    }
    return _formatter;
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
    
    //
    // NB need two classes here as we need two identifiers to prevent the wrong symbol being used
    //
    static NSString *kmlIdentifier = @"kmlIdentifier";
    static NSString *userIdentifier = @"userIdentifier";
    
    AnnotationView *annotationView;
    
    if ( [annotation isKindOfClass:[UserLocation class]]) {
        annotationView = (AnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:userIdentifier];
        
        if (annotationView == nil) {
            annotationView = [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userIdentifier];
        }
    } else {
        annotationView = (KMLAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kmlIdentifier];
        
        if (annotationView == nil) {
            annotationView = [[KMLAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kmlIdentifier];
        }
    }
    
    UserLocation *location = (UserLocation *)annotation;
    
    if ( [location selected] == [NSNumber numberWithBool:YES ] ) {
        [annotationView setImage:[UIImage imageNamed:@"annotation-view-selected"]];
    }
    
    [annotationView setText:annotation.title];
    
    double xOffset = 0.0f;
    double yOffset = -(pin_height/2);
    
    [annotationView setCenterOffset:CGPointMake(xOffset, yOffset)];
    
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    AnnotationDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    [detailViewController setDelegate:self];
    [detailViewController setAnnotation:view.annotation];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
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
#pragma mark  - PSLocationManagerDelegate methods
//////////////////////////////////////////////////////////////

- (void)locationManager:(PSLocationManager *)locationManager signalStrengthChanged:(PSLocationManagerGPSSignalStrength)signalStrength {
    NSString *strengthText;
    if (signalStrength == PSLocationManagerGPSSignalStrengthWeak) {
        strengthText = NSLocalizedString(@"Weak", @"");
    } else if (signalStrength == PSLocationManagerGPSSignalStrengthStrong) {
        strengthText = NSLocalizedString(@"Strong", @"");
    } else {
        strengthText = NSLocalizedString(@"...", @"");
    }
    
    [signalStrengthLabel setText:[NSString stringWithFormat:@"Signal strength: %@", strengthText]];
    [signalStrengthLabel setFont:[UIFont fontWithName:@"Whitney-Book" size:12]];
    NSLog(@"%@", strengthText);
}

- (void)locationManagerSignalConsistentlyWeak:(PSLocationManager *)locationManager {
    NSLog(@"%@", NSLocalizedString(@"Consistently Weak", @""));
}

- (void)locationManager:(PSLocationManager *)locationManager distanceUpdated:(CLLocationDistance)distance {
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f %@", distance, NSLocalizedString(@"meters", @"")]);
}

- (void)locationManager:(PSLocationManager *)locationManager waypoint:(CLLocation *)waypoint calculatedSpeed:(double)calculatedSpeed {
    NSLog(@"New location : %.4f/%.4f", waypoint.coordinate.latitude, waypoint.coordinate.longitude );

    double miles = 12.0;
    double scalingFactor =
    ABS( cos(2 * M_PI * waypoint.coordinate.latitude /360.0) );

    MKCoordinateSpan span;
    span.latitudeDelta = miles/69.0;
    span.longitudeDelta = miles/( scalingFactor*69.0 );

    mapView.showsUserLocation = YES;

    NSLog(@"Location manager update %.4f/%.4f", waypoint.coordinate.latitude, waypoint.coordinate.longitude);

    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude);

    NSLog(@"currentLocation (from self.latitude/longitude...) : %.4f/%.4f", currentLocation.latitude, currentLocation.longitude);

    self.latitude = waypoint.coordinate.latitude;
    self.longitude = waypoint.coordinate.longitude;
}
    

- (void)locationManager:(PSLocationManager *)locationManager error:(NSError *)error {    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services error" message:@"Unable to determine location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)viewDidUnload {
    signalStrengthLabel = nil;
    [super viewDidUnload];
}
@end
