//
//  UserAnnotationView.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AnnotationView : MKAnnotationView

@property (nonatomic, strong) UILabel *annotationLabel;
@property (nonatomic, strong) NSString *imagePath;

-(void)setText:(NSString *)text;

@end
