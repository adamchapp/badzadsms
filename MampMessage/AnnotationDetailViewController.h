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
#import "DeviceNameUtil.h"
#import "Constants.h"

@protocol AnnotationDetailViewDelegate <MFMessageComposeViewControllerDelegate>

/**
 Sends an SMS. The message content depends on whether the title is the same as the sender name.
 */
- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude;
- (void)deleteSelectedAnnotation:(id <MKAnnotation>)annotation;

@end

@interface AnnotationDetailViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<AnnotationDetailViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (strong, nonatomic) id <MKAnnotation> annotation;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

- (IBAction)sendSMS:(id)sender;
- (IBAction)removeAnnotation:(id)sender;

@end
