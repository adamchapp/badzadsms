//
//  HistoryViewController.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location+Extensions.h"
#import "KMLLocation.h"
#import "UserLocation+Extensions.h"
#import "LocationModel.h"
#import "AnnotationDelegate.h"

@interface HistoryViewController : UITableViewController

@property (nonatomic, assign) id<AnnotationDelegate> delegate;

@property (nonatomic, strong) LocationModel *locationModel;

@end
