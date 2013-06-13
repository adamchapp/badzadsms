//
//  MapItemCreator.h
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLParser.h"
#import "Location+Extensions.h"
#import "Overlay+Extensions.h"

@interface MapItemCreator : NSObject

- (Location *)locationFromURL:(NSURL *)url parser:(URLParser *)parser formatter:(NSDateFormatter *)formatter;
- (Overlay *)overlayFromURL:(NSURL *)url;

@end
