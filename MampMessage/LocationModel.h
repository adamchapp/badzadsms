//
//  LocationModel.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZLocation.h"
#import "BZOverlay.h"

@interface LocationModel : NSObject

@property (strong, nonatomic) NSMutableArray *coordinates;
@property (strong, nonatomic) NSMutableDictionary *coordinateDisplayMap;

@property (strong, nonatomic) NSMutableArray *overlays;
@property (strong, nonatomic) NSMutableDictionary *overlayDisplayMap;

- (void)addLocation:(BZLocation *)location;
- (void)removeLocationAtIndex:(NSInteger)index;

- (void)showLocation:(BZLocation *)location;
- (void)hideLocation:(BZLocation *)location;


- (void)addOverlay:(BZOverlay *)overlay;
- (void)removeOverlayAtIndex:(NSInteger)index;

- (void)showOverlay:(BZOverlay *)overlay;
- (void)hideOverlay:(BZOverlay *)overlay;

- (NSString *)makeKeyFromLocation:(BZLocation *)location;
- (NSString *)makeKeyFromOverlay:(BZOverlay *)overlay;

@end
