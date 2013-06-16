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
    [self.navigationItem setTitle:@"Location"];
    
    [self.topLabel setFont:[UIFont fontWithName:@"WhitneyCondensed-Black" size:19]];
    [self.bottomLabel setFont:[UIFont fontWithName:@"Whitney-Book" size:17]];
    
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.topLabel setText:self.annotation.title];
    
    NSString *creationTimeAndUserString = [NSString stringWithFormat:@"Created on %@", self.annotation.subtitle];
    
    [self.bottomLabel setText:creationTimeAndUserString];
    
    UIImageView *pin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation-view-menu"]];
    [pin setFrame:CGRectMake(0, 0, 29, 40)];
    [pin setCenter:self.mapView.center];
    
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 250, 250);
    [self.mapView setCenterCoordinate:self.annotation.coordinate];
    
    [self.mapView addSubview:pin];
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
