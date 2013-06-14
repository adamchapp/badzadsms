//
//  UserLocation.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * title;

@end
