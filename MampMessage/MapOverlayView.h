//
//  MapOverlayView.h
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapOverlayView : MKOverlayView
{
    CGFloat tileAlpha;
}

@property (nonatomic, assign)CGFloat overlayAlpha;

@end
