//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZLocation.h"

@interface LocationModel : NSObject

@property (strong, nonatomic) NSMutableArray *coordinates;
@property (strong, nonatomic) NSMutableDictionary *coordinateDisplayMap;

- (void)addLocation:(BZLocation *)location;
- (void)removeLocation:(BZLocation *)location;

- (void)showLocation:(BZLocation *)location;
- (void)hideLocation:(BZLocation *)location;

- (NSString *)makeKeyFromLocation:(BZLocation *)location;

@end
