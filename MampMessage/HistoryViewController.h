//
//  HistoryViewController.h
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZLocation.h"
#import "LocationModel.h"

@interface HistoryViewController : UITableViewController

@property (nonatomic, strong) LocationModel *locationModel;

@end