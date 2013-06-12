//
//  HistoryViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "MMSideDrawerTableViewCell.h"
#import "MMSideDrawerSectionHeaderView.h"
#import "HistoryViewController.h"
#import "Constants.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"History view init");
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed:49.0/255.0
                                                      green:54.0/255.0
                                                       blue:57.0/255.0
                                                      alpha:1.0]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:77.0/255.0
                                                       green:79.0/255.0
                                                        blue:80.0/255.0
                                                       alpha:1.0]];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:66.0/255.0
                                                  green:69.0/255.0
                                                   blue:71.0/255.0
                                                  alpha:1.0]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistoryView:) name:BZCoordinateDataChanged object:nil];
}

- (void)reloadHistoryView:(id)sender {
    NSLog(@"Reloading history view items");
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  //  [self.locationModel removeObserver:self forKeyPath:@"coordinates" context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma mark  - UITableView data source
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return [self.locationModel.coordinates count];
    }
    return [self.locationModel.overlays count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( !cell ) {
        cell = [[MMSideDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    NSString *title;
    BOOL showCoordinate;
    
    if ( indexPath.section == 0 ) {
        BZLocation *location = [self.locationModel.coordinates objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@ %@",location.title, location.subtitle];
        showCoordinate = location.isVisible;
    } else {
        BZOverlay *overlay = [self.locationModel.overlays objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@", overlay.title];
        showCoordinate = overlay.isVisible;
    }
    
    cell.textLabel.text = title;
    
    if ( showCoordinate == YES ) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Recent History";
        case 1:
            return @"Overlays";
        default:
            return nil;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MMSideDrawerSectionHeaderView * headerView =  [[MMSideDrawerSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 20.0f)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [headerView setTitle:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 23.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        [tableView beginUpdates];
        
        if ( indexPath.section == 0 ) {
            BZLocation *location = [self.locationModel.coordinates objectAtIndex:indexPath.row];
            
            [self.locationModel removeLocation:location];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } else if ( indexPath.section == 1 ) {
            BZOverlay *overlay = [self.locationModel.overlays objectAtIndex:indexPath.row];
            
            [self.locationModel removeOverlay:overlay];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [tableView endUpdates];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ( indexPath.section == 0 ) {
        BZLocation *location = [[self.locationModel coordinates] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.locationModel showLocation:location];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self.locationModel hideLocation:location];
        }        
    } else {
        BZOverlay *overlay = [[self.locationModel overlays] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.locationModel showOverlay:overlay];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self.locationModel hideOverlay:overlay];
        }
    }
    
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////



@end
