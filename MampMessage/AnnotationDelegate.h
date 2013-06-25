//
//  AnnotationDelegate.h
//  MapMessage
//
//  Created by Nucleus on 25/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnotationDelegate <MFMessageComposeViewControllerDelegate>

/**
 Sends an SMS. The message content depends on whether the title is the same as the sender name.
 */
- (void)sendSMSNamed:(NSString *)title timestamp:(NSString *)timestamp latitude:(double)latitude longitude:(double)longitude;
- (void)deleteSelectedAnnotation:(id <MKAnnotation>)annotation;

@end
