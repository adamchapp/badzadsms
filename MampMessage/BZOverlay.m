//
//  BZOverlay.m
//  MapMessage
//
//  Created by Nucleus on 10/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "BZOverlay.h"

@implementation BZOverlay

-(id)initWithTitle:(NSString *)title overlays:(NSArray *)overlays
{
    self = [super init];
    
    if ( self ) {
        self.title = title;
        self.overlays = overlays;
    }
    
    return self;
}

- (NSString *)title {
    return _title;
}

- (NSArray *)overlays {
    return _overlays;
}

@end
