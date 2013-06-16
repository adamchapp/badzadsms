//
//  MMRootViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
{
    NSInteger pin_width;
    NSInteger pin_height;
}

@property (strong, nonatomic) MMDrawerBarButtonItem *leftDrawerButtonItem;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UIButton *saveAnnotationButton;
@property (nonatomic, strong) UIButton *cancelAnnotationButton;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

@synthesize locationManager = _locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pin_width = 29;
    pin_height = 40;
    
    [self.navigationController setTitle:@"Back"];
    
    [self createMenuButtons];
    [self addGestureRecognisers];
    [self addObservers];
    [self setupLocationManager];
    [self loadAnnotations];
    [self setStartingLocation];
    
    [self setEditing:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma mark  - Startup methods
//////////////////////////////////////////////////////////////

- (void)createMenuButtons{
    self.leftDrawerButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    
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
    longPress.minimumPressDuration = 1.0;
    [mapView addGestureRecognizer:longPress];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateDataChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAnnotations) name:BZCoordinateViewDataChanged object:nil];
}

- (void)setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)loadAnnotations {
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
    
    [mapView addOverlays:self.locationModel.mapTileCollectionViews];
    
    for ( NSArray *annotations in self.locationModel.kmlLocationViews ) {
        [mapView addAnnotations:annotations];
    }
    
    //load user annotations
    for (UserLocation *location in self.locationModel.userLocations) {
        if (  [[location isVisible] boolValue] == YES ) {
            [mapView addAnnotation:location];
        }
    }
}

- (void)deleteSelectedAnnotation:(id<MKAnnotation>)annotation
{
    if ( [annotation isKindOfClass:[UserLocation class]] ) {
        NSLog(@"Removing annotation");
        [self.locationModel removeUserLocation:(UserLocation *)annotation];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)setStartingLocation
{
    // Set the starting game location.
    CLLocationCoordinate2D startingLocation;
    startingLocation.latitude = 51.154047246473084;
    startingLocation.longitude =-2.5871944427490234;
    
    mapView.region = MKCoordinateRegionMakeWithDistance(startingLocation, 1000, 1000);
    [mapView setCenterCoordinate:startingLocation];
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
    
    self.dropPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop-pin"]];
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
                        options:UIViewAnimationOptionCurveEaseIn
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
                        options:UIViewAnimationOptionCurveEaseOut
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
    
    [self.locationModel addUserLocationWithTitle:self.pinViewHeader.textField.text
                                          sender:[DeviceNameUtil nameFromDevice]
                                       timestamp:[NSDate date]
                                        latitude:coordinates.latitude
                                       longitude:coordinates.longitude
                                       isVisible:YES];
        
    [self removeNewAnnotationView];
}

- (IBAction)handleSMSButtonClicked:(id)sender
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BZDateFormat];
    
    NSString *timestamp = [formatter stringFromDate:date];
    NSString *name = [DeviceNameUtil nameFromDevice];
    
    [self sendSMSNamed:name timestamp:timestamp latitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
}

- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude
{
    [self.smsController sendSMSNamed:title timestamp:timestamp latitude:latitude longitude:longitude];
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

- (void)hideKeyboard:(id)sender {
    [self.pinViewHeader hideKeyboard:sender];
}

- (void)toggleAnnotationLabelColors:(BOOL)isWhite
{
    for (id<MKAnnotation> annotation in mapView.annotations){
        
        if ( ![annotation isKindOfClass:[MKUserLocation class]]) {
            
            KMLAnnotationView* view = (KMLAnnotationView *)[mapView viewForAnnotation:annotation];
            if (view){
                
                UIColor *textColor = (isWhite == YES) ? [UIColor whiteColor] : [UIColor blackColor];
                [view.annotationLabel setTextColor:textColor];
            }
        }
    }
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

        [self.navigationItem setLeftBarButtonItem:self.leftDrawerButtonItem animated:NO];
        [self.navigationItem setRightBarButtonItem:standardRightBarButtonItem animated:NO];
        
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]]];
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
        _pinViewHeader = [[PinViewHeader alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    }
    return _pinViewHeader;
}

- (SMSController *)smsController {
    if ( !_smsController ) {
        _smsController = [[SMSController alloc] initWithRootViewController:self];
    }
    return _smsController;
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
   
    static NSString *kmlIdentifier = @"kmlIdentifier";
    static NSString *userIdentifier = @"userIdentifier";
    
    if ( [annotation isKindOfClass:[UserLocation class]]) {
        UserAnnotationView *annotationView = (UserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:userIdentifier];
        
        if (annotationView == nil) {
            annotationView = [[UserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userIdentifier];
        }
        [annotationView.annotationLabel setText:[annotation title]];
        
        return annotationView;
    } else {
        KMLAnnotationView *annotationView = (KMLAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kmlIdentifier];
        
        if (annotationView == nil) {
            annotationView = [[KMLAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kmlIdentifier];
        }
        [annotationView.annotationLabel setText:[annotation title]];
        
        return annotationView;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Show detail screen");
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
