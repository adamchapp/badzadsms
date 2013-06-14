//
//  MapTileCollection+Extension.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MapTileCollection+Extension.h"

@implementation MapTileCollection (Extension)

- (id)initWithName:(NSString *)title directoryPath:(NSString *)path isVisible:(BOOL)visible
{
    self = [super init];
    
    if ( self ) {
        self.title = title;
        self.directoryPath = path;
        self.isVisible = [NSNumber numberWithBool:visible];
    }
    
    return self;
}
@end
