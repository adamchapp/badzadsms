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

    if(self.navigationController.viewControllers.count > 1) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [backButton setBackgroundImage:[UIImage imageNamed:@"back-button"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(0.0f, 0.0f, 49.0f, 17.0f);
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
    
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
    
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.creationDateLabel = nil;
    self.mapView = nil;
}

- (IBAction)sendSMS:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BZDateFormat];

    NSDate *date = [NSDate date];
    NSString *formattedTimeStamp = [formatter stringFromDate:date];
    
    [self.delegate sendSMSNamed:self.annotation.title timestamp:formattedTimeStamp latitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
}

- (IBAction)removeAnnotation:(id)sender {
    [self.delegate deleteSelectedAnnotation:self.annotation];
}

- (IBAction)openLinkInExternalMapApp:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open in" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps", @"Google Maps", nil];
    [actionSheet showInView:self.view];
}

//////////////////////////////////////////////////////////////
#pragma mark  - UIActionSheetDelegate methods
//////////////////////////////////////////////////////////////

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked actionsheet");
    if ( buttonIndex == 0 ) {
        NSDictionary *addressDict = @{
                                      (NSString *) kABPersonAddressStreetKey : self.annotation.title,
                                      };

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.annotation.coordinate addressDictionary:addressDict];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem openInMapsWithLaunchOptions:nil];
    } else if ( buttonIndex == 1 ) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",self.annotation.coordinate.latitude,self.annotation.coordinate.longitude]];
        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            NSLog(@"Google Maps app is not installed");
            //left as an exercise for the reader: open the Google Maps mobile website instead!
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You do not have the Google Maps iOS app installed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark  - Gesture recognizer methods
//////////////////////////////////////////////////////////////

-(UITapGestureRecognizer *)gestureRecognizer {
    
    if ( !_gestureRecognizer ) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        _gestureRecognizer.delegate = self;
        _gestureRecognizer.cancelsTouchesInView = NO;
    }
    
    return _gestureRecognizer;
}

@end
