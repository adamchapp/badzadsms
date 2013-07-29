//
//  OverlayImportController.h
//  OverlayImporter
//
//  Created by Nucleus on 19/07/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OverlayImportControllerDelegate <NSObject>

- (void)addMapTileCollectionWithName:(NSString *)name directoryPath:(NSString *)path isFlippedAxis:(BOOL)flipped;

@end

@interface OverlayImportController : NSObject

@property (nonatomic, weak) id<OverlayImportControllerDelegate> delegate;

- (BOOL)addOverlayToDocumentsDirectory:(NSURL *)url;

@end
