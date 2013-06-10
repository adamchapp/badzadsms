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
#import "BZLocation.h"
#import "URLParser.h"
#import "LocationModel.h"
#import "MMDrawerBarButtonItem.h"

@interface MapViewController : UIViewController <MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView *mapView;
}

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@property (strong, nonatomic) LocationModel *locationModel;

- (void)loadAnnotations;
- (IBAction)sendSMS:(id)sender;
- (IBAction)toggleCompass:(id)sender;

@end
