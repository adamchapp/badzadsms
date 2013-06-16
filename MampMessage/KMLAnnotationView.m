//
//  CustomAnnotationView.m
//  MapMessage
//
//  Created by Adam Chappell on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "KMLAnnotationView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation KMLAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30,-32,85,48)];
        [self.annotationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.annotationLabel setFont:[UIFont fontWithName:@"Whitney-Light" size:12]];
        [self.annotationLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.annotationLabel];

        self.image = [UIImage imageNamed:[self pathForUnselectedImage]];
        self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        self.canShowCallout = YES;
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if ( selected ) {
        self.image = [UIImage imageNamed:@"annotation-view"];
        [self.annotationLabel setHidden:YES];
    } else {
        self.image = [UIImage imageNamed:[self pathForUnselectedImage]];
        [self.annotationLabel setHidden:NO];
    }
}

-(NSString *)pathForUnselectedImage {
    return @"annotation-view-unselected";
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
