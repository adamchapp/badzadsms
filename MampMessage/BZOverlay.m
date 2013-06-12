//
//  BZOverlay.m
//  MapMessage
//
//  Created by Nucleus on 10/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "BZOverlay.h"

@implementation BZOverlay

-(id)initWithTitle:(NSString *)title path:(NSString *)overlayPath isVisible:(BOOL)visible
{
    self = [super init];
    
    if ( self ) {
        self.title = title;
        self.overlayPath = overlayPath;
        self.isVisible = visible;
    }
    
    return self;
}

- (BOOL)visible {
    return _isVisible;
}

- (NSString *)title {
    return _title;
}

- (NSString *)overlayPath  {
    return _overlayPath;
}

@end
