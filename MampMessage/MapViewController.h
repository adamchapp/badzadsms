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
#import <QuartzCore/QuartzCore.h>
#import "PSLocationManager.h"

#import "Constants.h"

#import "ECSlidingViewController.h"
#import "HistoryViewController.h"
#import "PinViewHeader.h"
#import "AnnotationDetailViewController.h"

#import "LocationModel.h"
#import "UserLocation+Extensions.h"
#import "KMLLocation+Extensions.h"

#import "URLParser.h"

#import "KMLAnnotationView.h"
#import "AnnotationView.h"
#import "MapOverlay.h"
#import "MapOverlayView.h"

#import "DeviceNameUtil.h"
#import "SMSController.h"
#import "AnnotationDelegate.h"

typedef void (^ConfirmAddLocationBlock)(void);

@interface MapViewController : UIViewController <MFMessageComposeViewControllerDelegate, PSLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, AnnotationDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *compassButton;
    IBOutlet UIButton *satelliteButton;
}

@property (nonatomic, copy) ConfirmAddLocationBlock confirmBlock;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (strong, nonatomic) UIImageView *dropPin;

@property (strong, nonatomic) LocationModel *locationModel;

@property (nonatomic, strong) SMSController *smsController;

@property (nonatomic, strong) PinViewHeader *pinViewHeader;

- (void)loadAnnotations;
- (IBAction)handleSMSButtonClicked:(id)sender;
- (IBAction)toggleCompass:(id)sender;
- (IBAction)toggleViewMode:(id)sender;

- (void)addUserLocationFromURL:(NSURL *)url;
- (void)addKMLLocationFromURL:(NSURL *)url;

@end
