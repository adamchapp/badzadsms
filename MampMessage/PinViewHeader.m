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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

    UIColor *shadowColor = [UIColor colorWithRed:0.776 green:0.776 blue:0.773 alpha:1];
    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
    CGFloat shadowBlurRadius = 2;
        
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 320, 32)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
    [fillColor setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
}

- (void)loadSubviews {
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 55, 28)];
    [nameLabel setText:@"Name:"];
    [nameLabel setTextColor:[UIColor lightGrayColor]];
    [nameLabel setFont:[UIFont fontWithName:@"Whitney-Book" size:18]];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(85, 4, 210, 28)];
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
