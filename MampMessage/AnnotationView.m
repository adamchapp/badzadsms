//
//  UserAnnotationView.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "AnnotationView.h"
#import "Location+Extensions.h"

@implementation AnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [UIImage imageNamed:[self pathForUnselectedImage]];
        self.canShowCallout = YES;
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        self.annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,125,24)];
        [self.annotationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.annotationLabel setFont:[UIFont fontWithName:@"Whitney-Semibold" size:14]];
        [self.annotationLabel setBackgroundColor:rgb(216,223,219)];
        [self.annotationLabel setAlpha:0.7];
        [self.annotationLabel setNumberOfLines:1];
                
        [self addSubview:self.annotationLabel];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    Location *location = (Location *)self.annotation;
    
    //if this annotation is the current destination, just show that image
    //otherwise toggle between selected and unselected    
    if ( [location.selected boolValue] == YES ) {
        NSLog(@"[AV] this location (%@) is current destination, use destination icon", location.title);
        self.image = [UIImage imageNamed:@"annotation-view-destination"];
    } else {
        if ( selected ) {
            NSLog(@"[AV] this location (%@) is selected", location.title);
            self.image = [UIImage imageNamed:@"annotation-view-selected"];
        } else {
            NSLog(@"[AV] this location (%@) is not selected", location.title);
            self.image = [UIImage imageNamed:[self pathForUnselectedImage]];
        }
    }
    
    if ( selected ) {
        [self.annotationLabel setHidden:YES];
    } else {
        [self.annotationLabel setHidden:NO];
    }

}

-(NSString *)pathForUnselectedImage {
    return @"annotation-view-unselected";
}

- (void)setText:(NSString *)text {
    [self.annotationLabel setText:text];
    [self.annotationLabel sizeToFit];
    [self.annotationLabel setCenter:CGPointMake((self.frame.size.width/2), -10)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
