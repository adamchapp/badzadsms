//
//  MMRootViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MMRootViewController.h"


@interface MMRootViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MMRootViewController

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

-(void)loadAnnotations {
    
    NSLog(@"Loading annotations");
    
    if ( [self.coordinates count] > 0 ) {
        NSLog(@"Adding annotations");
        [self.mapView addAnnotations:self.coordinates];
    } else {
        NSLog(@"No annotations to add");
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendSMS:(id)sender
{
    if ( [MFMessageComposeViewController canSendText] ) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        NSString *timestamp = [formatter stringFromDate:date];
        
        NSString *urlString = [NSString stringWithFormat:@"Adam sent you his new location at %@. \n\nbadzad://badzad.com/message?lat=%@&long=%@&title=%@&timestamp=%@", timestamp, self.latitude.text, self.longitude.text, @"Adam", timestamp];
        
        controller.body = urlString;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        NSLog(@"Cannot send SMS from this device");
    }
}

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
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = newLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
    self.mapView.showsUserLocation = YES;
    
    self.latitude.text =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitude.text =
    [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alertView;
    
    switch (result) {
        case MessageComposeResultSent:
            alertView = [[UIAlertView alloc] initWithTitle:@"Message sent" message:@"Your updated location has been sent" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            break;
      
        case MessageComposeResultCancelled:
            alertView = [[UIAlertView alloc] initWithTitle:@"Message sending failed" message:@"Your updated location could not been sent" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            break;
            
        default:
            break;
    }
    
    [alertView show];
}

- (NSMutableArray *)coordinates
{
    if ( !_coordinates ) {
        _coordinates = [NSMutableArray array];
    }
    return _coordinates;
}

@end
