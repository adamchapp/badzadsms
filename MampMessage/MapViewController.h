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
#import "UserLocation+Extensions.h"
#import "KMLLocation+Extensions.h"
#import "ECSlidingViewController.h"
#import "Constants.h"
#import "URLParser.h"
#import "KMLAnnotationView.h"
#import "UserAnnotationView.h"
#import "MapOverlay.h"
#import "MapOverlayView.h"
#import "PinViewHeader.h"
#import "DeviceNameUtil.h"
#import "SMSController.h"
#import "AnnotationDetailViewController.h"

@interface MapViewController : UIViewController <MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, AnnotationDetailViewDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *compassButton;
    IBOutlet UIButton *satelliteButton;
}

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@property (strong, nonatomic) UIImageView *dropPin;

@property (strong, nonatomic) LocationModel *locationModel;

@property (nonatomic, strong) SMSController *smsController;

@property (nonatomic, strong) PinViewHeader *pinViewHeader;

- (void)loadAnnotations;
- (IBAction)handleSMSButtonClicked:(id)sender;
- (IBAction)toggleCompass:(id)sender;
- (IBAction)toggleViewMode:(id)sender;

@end
