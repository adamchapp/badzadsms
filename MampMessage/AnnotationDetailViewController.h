//
//  AnnotationDetailViewController.h
//  MapMessage
//
//  Created by Adam Chappell on 15/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import "DeviceNameUtil.h"
#import "Constants.h"
#import "AnnotationDelegate.h"

@interface AnnotationDetailViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) id<AnnotationDelegate> delegate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@property (strong, nonatomic) id <MKAnnotation> annotation;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

- (IBAction)sendSMS:(id)sender;
- (IBAction)removeAnnotation:(id)sender;
- (IBAction)openLinkInExternalMapApp:(id)sender;

@end
