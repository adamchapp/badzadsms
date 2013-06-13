//
//  MapItemCreator.m
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MapItemCreator.h"

@implementation MapItemCreator

- (Location *)locationFromURL:(NSURL *)url parser:(URLParser *)parser formatter:(NSDateFormatter *)formatter
{
    NSString *title = [parser valueForVariable:@"title"];
    NSString *timeStampString = [parser valueForVariable:@"timestamp"];
    
    NSDate *timestamp = [formatter dateFromString:timeStampString];
    
    double latitude = [[parser valueForVariable:@"lat"] doubleValue];
    double longitude = [[parser valueForVariable:@"long"] doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    Location *location = [[Location alloc] initWithName:title timestamp:timestamp coordinate:coordinate isVisible:YES];
    
    return location;
}

- (Overlay *)overlayFromURL:(NSURL *)url
{
    NSString *filenameWithExtension = [url lastPathComponent];
    NSString *filename = [filenameWithExtension stringByDeletingPathExtension];
    
    Overlay *overlay = [[Overlay alloc] initWithTitle:filename path:url.path isVisible:YES];
    
    return overlay;
}

@end
