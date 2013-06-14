//
//  MapTile.m
//  GameMap
//
//  Created by Nathanael De Jager on 11-12-27.
//  Copyright (c) 2011 Nathanael De Jager. All rights reserved.
//

#import "MapTile.h"

@implementation MapTile

@synthesize path;
@synthesize frame;

- (id)initWithFrame:(MKMapRect)tileFrame path:(NSString *)tilePath
{
    if( self = [super init])
    {
        path = tilePath;
        frame = tileFrame;
    }
    return self;
}

@end
