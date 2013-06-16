//
//  PinView.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinViewHeader : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;

- (void)hideKeyboard:(id)sender;

@end
