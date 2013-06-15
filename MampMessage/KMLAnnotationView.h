//
//  CustomAnnotationView.h
//  MapMessage
//
//  Created by Adam Chappell on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMLAnnotationView : MKAnnotationView

@property (nonatomic, strong) UILabel *annotationLabel;

@end
