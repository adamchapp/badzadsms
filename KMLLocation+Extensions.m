//
//  KMLLocation+Extensions.m
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "KMLLocation+Extensions.h"

@implementation KMLLocation (Extensions)

- (id)initWithTitle:(NSString *)title path:(NSString *)overlayPath isVisible:(BOOL)visible
{
    self = [super init];
    
    if ( self ) {
        self.title = title;
        self.locationFilePath = overlayPath;
        self.isVisible = [NSNumber numberWithBool:visible];
    }
    
    return self;
}

+ (KMLLocation *)locationFromURL:(NSURL *)url
{
    NSString *filenameWithExtension = [url lastPathComponent];
    NSString *filename = [filenameWithExtension stringByDeletingPathExtension];
    
    KMLLocation *kmlLocation = [[self alloc] initWithTitle:filename path:url.path isVisible:YES];
    
    return kmlLocation;
}

@end
