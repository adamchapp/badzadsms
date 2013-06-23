//
//  UserLocation.h
//  MapMessage
//
//  Created by Adam Chappell on 22/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"


@interface UserLocation : Location

@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSDate * timestamp;

@end
