//
//  KMLLocation.h
//  MapMessage
//
//  Created by Adam Chappell on 14/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KMLLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSString * overlayPath;
@property (nonatomic, retain) NSString * title;

@end
