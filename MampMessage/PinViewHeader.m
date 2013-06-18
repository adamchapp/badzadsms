//
//  PinView.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "PinViewHeader.h"

@implementation PinViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
        
    UIColor *fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    UIColor *underlineColor = [UIColor colorWithRed:0.776 green:0.776 blue:0.773 alpha:1];
        
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 320, 42)];
    [fillColor setFill];
    [rectanglePath fill];
    
    UIBezierPath *underline = [UIBezierPath bezierPathWithRect:CGRectMake(0, 43, 320, 44)];
    [underlineColor setFill];
    [underline fill];
}

- (void)loadSubviews {
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 55, 28)];
    [nameLabel setText:@"Name:"];
    [nameLabel setTextColor:[UIColor lightGrayColor]];
    [nameLabel setFont:[UIFont fontWithName:@"Whitney-Book" size:18]];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(85, 6, 210, 28)];
    [self.textField setOpaque:NO];
    [self.textField setBorderStyle:UITextBorderStyleNone];
    [self.textField setFont:[UIFont fontWithName:@"Whitney-Book" size:18]];
    [self.textField setDelegate:self];
    
    [self addSubview:nameLabel];
    [self addSubview:self.textField];
}


//////////////////////////////////////////////////////////////
#pragma mark  - UITextFieldDelegate methods
//////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)hideKeyboard:(id)sender
{
    NSLog(@"is this being called too much");
   [self.textField endEditing:NO];
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////

-(UITapGestureRecognizer *)gestureRecognizer {

    if ( !_gestureRecognizer ) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        _gestureRecognizer.delegate = self;
        _gestureRecognizer.cancelsTouchesInView = NO;
    }
        
    return _gestureRecognizer;
}



@end
