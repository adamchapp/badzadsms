//
//  SMSController.h
//  MapMessage
//
//  Created by Adam Chappell on 15/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "DeviceNameUtil.h"

@interface SMSController : NSObject

@property (nonatomic, assign) id<MFMessageComposeViewControllerDelegate> viewController;

- (id)initWithRootViewController:(id<MFMessageComposeViewControllerDelegate>)controller;

- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude;

@end
