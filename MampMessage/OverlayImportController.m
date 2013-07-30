//
//  OverlayImportController.m
//  OverlayImporter
//
//  Created by Nucleus on 19/07/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "OverlayImportController.h"
#import "ZipArchive.h"

@interface OverlayImportController ()

@property (nonatomic, strong) NSString *mapName;

@end

@implementation OverlayImportController

- (BOOL)addOverlayToDocumentsDirectory:(NSURL *)url
{
    NSLog(@"%@", url.lastPathComponent);
    
    __block BOOL unzip;
 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        unzip = [self downloadZipFileToDocumentsDirectory:url];
        
        NSString *overlayTitle = [url.lastPathComponent stringByDeletingPathExtension];
        
        if ( unzip ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate addMapTileCollectionWithName:self.mapName directoryPath:self.mapName isFlippedAxis:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful import" message:[NSString stringWithFormat:@"Added %@ as a map overlay", overlayTitle] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was an error trying to import %@", overlayTitle] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });
        }
    });
    
    return unzip;
}

- (BOOL)downloadZipFileToDocumentsDirectory:(NSURL *)url {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    BOOL unzippedCorrectly = NO;
    
    if(!error)
    {
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSArray *savePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *savePath = [savePaths objectAtIndex:0];
        NSString *cachePath = [cachePaths objectAtIndex:0];
        
        NSString *zipPath = [cachePath stringByAppendingPathComponent:url.lastPathComponent];
                
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            NSLog(@"Created temp ZIP, unzipping");
            
            NSMutableArray *fileContents = [self unzipFileAtPath:zipPath toSavePath:savePath];
            
            NSLog(@"Saving to path %@", savePath);
            
            if ( fileContents != nil ) {
                
                NSLog(@"Delete original downloaded zip");
                NSString *uncleanName = [fileContents objectAtIndex:0];
                
                self.mapName = [uncleanName stringByReplacingOccurrencesOfString:@"/" withString:@""];

                NSLog(@"Let's get the filename %@", self.mapName);
                
                //clean up
                NSURL *originalZipURL = url;
                NSURL *createdZipURL = [NSURL URLWithString:url.lastPathComponent relativeToURL:[NSURL URLWithString:savePath]];
                
                [[NSFileManager defaultManager] removeItemAtURL:originalZipURL error:&error];
                [[NSFileManager defaultManager] removeItemAtURL:createdZipURL error:&error];
                
                unzippedCorrectly = YES;
                
                return unzippedCorrectly;
            }
        }
        else
        {
            NSLog(@"Error saving file %@",error);
            return unzippedCorrectly;
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", error);
        return unzippedCorrectly;
    }
    
    return unzippedCorrectly;
}

- (NSMutableArray *)unzipFileAtPath:(NSString *)zipPath toSavePath:(NSString *)savePath
{
    NSLog(@"Zip path is %@", zipPath);
    NSMutableArray *contents;
    BOOL ret = NO;
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: zipPath]) {
        NSLog(@"Available for unzipping");
        ret = [za UnzipFileTo: savePath overWrite: YES];
        contents = [za getZipFileContents];
        if (NO == ret){} [za UnzipCloseFile];
    }
    
    return contents;
}

@end
