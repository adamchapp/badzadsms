//
//  PinView.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "PinView.h"

@implementation PinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    UIImageView *headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-with-text"]];
    
    self.cancelButton = [[UIButton alloc] init];
    [self.cancelButton setFrame:CGRectMake(244, 10, 24, 24)];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel-button"] forState:UIControlStateNormal];
    
    self.okButton = [[UIButton alloc] init];
    [self.okButton setFrame:CGRectMake(276, 10, 24, 24)];
    [self.okButton setBackgroundImage:[UIImage imageNamed:@"ok-button"] forState:UIControlStateNormal];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(26, 7, 214, 30)];
    [self.textField setOpaque:NO];
    [self.textField setPlaceholder:@"Enter a name for your pin"];
    [self.textField setBorderStyle:UITextBorderStyleNone];
    [self.textField setFont:[UIFont fontWithName:@"Whitney-Light" size:13]];
    
    [self addSubview:headerBackground];
    [self addSubview:self.cancelButton];
    [self addSubview:self.okButton];
}

@end
