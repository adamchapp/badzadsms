//
//  AnnotationDetailViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 15/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "AnnotationDetailViewController.h"

@interface AnnotationDetailViewController ()
{
    UITapGestureRecognizer *_gestureRecognizer;
}
@end

@implementation AnnotationDetailViewController

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    self = [super init];
    
    if ( self ) {
        self.annotation = annotation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.mapView setMapType:MKMapTypeHybrid];

    [self.navigationItem setTitle:self.annotation.title];
    [self.creationDateLabel setText:self.annotation.subtitle];    
    [self.latitudeLabel setText:[NSString stringWithFormat:@"%.4f", self.annotation.coordinate.latitude]];
    [self.longitudeLabel setText:[NSString stringWithFormat:@"%.4f", self.annotation.coordinate.longitude]];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-button"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)]];
    
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 250, 250);
    [self.mapView setCenterCoordinate:self.annotation.coordinate];
}
     
- (void)goBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendSMS:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BZReadableDateFormat];
    NSDate *formattedDate = [formatter dateFromString:self.annotation.subtitle];
    [formatter setDateFormat:BZDateFormat];
    NSString *formattedTimeStamp = [formatter stringFromDate:formattedDate];
    
    [self.delegate sendSMSNamed:self.annotation.title timestamp:formattedTimeStamp latitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
}

- (IBAction)removeAnnotation:(id)sender {
    [self.delegate deleteSelectedAnnotation:self.annotation];
}

- (IBAction)openLinkInGoogleMaps:(id)sender {
}

-(UITapGestureRecognizer *)gestureRecognizer {
    
    if ( !_gestureRecognizer ) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        _gestureRecognizer.delegate = self;
        _gestureRecognizer.cancelsTouchesInView = NO;
    }
    
    return _gestureRecognizer;
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"this would hide first responder if there was one");
}

@end
