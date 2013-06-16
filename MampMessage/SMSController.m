//
//  SMSController.m
//  MapMessage
//
//  Created by Adam Chappell on 15/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "SMSController.h"

@implementation SMSController

- (id)initWithRootViewController:(id<MFMessageComposeViewControllerDelegate>)controller
{
    self = [super init];
    
    if (self) {
        self.viewController = controller;
    }
    return self;
}

- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude
{
    if ( [MFMessageComposeViewController canSendText] ) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self.viewController;
        
        NSString *urlString;
        NSString *senderName = [DeviceNameUtil nameFromDevice];
        
        NSString *strippedTitle = [title stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        senderName = [senderName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        if ( [title isEqualToString:senderName] ) {
            urlString = [NSString stringWithFormat:@"%@ sent you their current location at %@. \n\nbadzad://mapmessage.com/message?lat=%.4f&long=%.4f&sender=%@&title=%@&timestamp=%@",senderName, timestamp, latitude, longitude, senderName, strippedTitle, timestamp];
        } else {
            urlString = [NSString stringWithFormat:@"%@ sent you a new location called %@ at %@. \n\nbadzad://mapmessage.com/message?lat=%.4f&long=%.4f&sender=%@&title=%@&timestamp=%@",senderName, title, timestamp, latitude, longitude, senderName, strippedTitle, timestamp];
        }
        
        controller.body = urlString;
        
        [(UIViewController *)self.viewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
