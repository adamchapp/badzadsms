//
//  Overlay+Extensiosn.m
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "Overlay+Extensions.h"

@implementation Overlay (Extensions)

- (id)initWithTitle:(NSString *)title path:(NSString *)overlayPath isVisible:(BOOL)visible
{
    self = [super init];
    
    if ( self ) {
        self.title = title;
        self.overlayPath = overlayPath;
        self.isVisible = [NSNumber numberWithBool:visible];
    }
    
    return self;
}

+ (Overlay *)overlayFromURL:(NSURL *)url
{
    NSString *filenameWithExtension = [url lastPathComponent];
    NSString *filename = [filenameWithExtension stringByDeletingPathExtension];
    
    Overlay *overlay = [[self alloc] initWithTitle:filename path:url.path isVisible:YES];
    
    return overlay;
}

@end
