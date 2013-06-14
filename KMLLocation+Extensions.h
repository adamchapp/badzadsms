//
//  KMLLocation+Extensions.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "KMLLocation.h"

@interface KMLLocation (Extensions)

- (id)initWithTitle:(NSString *)title path:(NSString *)overlayPath isVisible:(BOOL)visible;

+ (KMLLocation *)locationFromURL:(NSURL *)url;

@end
