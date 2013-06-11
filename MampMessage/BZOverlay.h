//
//  BZOverlay.h
//  MapMessage
//
//  Created by Nucleus on 10/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZOverlay : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *overlayPath;

-(id)initWithTitle:(NSString *)title path:(NSString *)overlayPath;

@end
