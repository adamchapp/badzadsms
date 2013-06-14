//
//  MMRootViewController.h
//  MapMessage
//
//  Created by Adam Chappell on 08/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "HistoryViewController.h"
#import "LocationModel.h"
#import "MMDrawerBarButtonItem.h"
#import "UserLocation+Extensions.h"
#import "KMLLocation+Extensions.h"
#import "UIViewController+MMDrawerController.h"
#import "Constants.h"
#import "KMLParser.h"
#import "URLParser.h"
#import "CustomAnnotationView.h"
#import "MapOverlay.h"
#import "MapOverlayView.h"
#import "PinView.h"

@interface MapViewController : UIViewController <MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *compassButton;
    IBOutlet UIButton *satelliteButton;
}

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

//@property (strong, nonatomic) PinView *pinView;

@property (strong, nonatomic) UIImageView *dropPin;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIImageView *headerBackground;

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) LocationModel *locationModel;
@property (strong, nonatomic) KMLParser *kmlParser;

- (void)loadAnnotations;
- (IBAction)sendSMS:(id)sender;
- (IBAction)toggleCompass:(id)sender;
- (IBAction)toggleViewMode:(id)sender;

@end
