//
//  Overlay.h
//  MapMessage
//
//  Created by Nucleus on 13/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Overlay : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * overlayPath;
@property (nonatomic, retain) NSNumber * isVisible;

@end
