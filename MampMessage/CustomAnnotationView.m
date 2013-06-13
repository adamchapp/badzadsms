//
//  CustomAnnotationView.m
//  MapMessage
//
//  Created by Adam Chappell on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30,-32,85,48)];
        [self.annotationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.annotationLabel setFont:[UIFont fontWithName:@"WhitneyCondensed-Black" size:12]];
        [self.annotationLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.annotationLabel];

        self.image = [UIImage imageNamed:@"annotation-view"];
        self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        self.canShowCallout = YES;
    }
    return self;
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
