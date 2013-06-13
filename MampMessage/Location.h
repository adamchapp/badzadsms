//
//  Location.h
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
