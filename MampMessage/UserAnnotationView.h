//
//  UserAnnotationView.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserAnnotationView : MKAnnotationView

@property (nonatomic, strong) UILabel *annotationLabel;

@end
