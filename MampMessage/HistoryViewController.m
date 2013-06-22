//
//  HistoryViewController.m
//  MapMessage
//
//  Created by Adam Chappell on 09/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "HistoryViewController.h"
#import "ECSlidingViewController.h"
#import "Constants.h"

@interface HistoryViewController ()

@property (nonatomic, strong) UIButton *editButton;

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
    
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 13)];
    [self.editButton addTarget:self action:@selector(toggleEditingMode) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"edit-button"] forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"done-button"] forState:UIControlStateSelected];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    
    self.navigationItem.leftBarButtonItem = editBarButtonItem;
    [self.navigationItem setTitle:@"Locations"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistoryView:) name:BZCoordinateDataChanged object:nil];
}

- (void)toggleEditingMode {
    NSLog(@"toggle editing");
    
    if ( self.isEditing ) {
        [self setEditing:NO animated:YES];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"edit-button"] forState:UIControlStateNormal];
        [self.editButton setFrame:CGRectMake(0, 0, 25, 13)];
    } else {
        [self setEditing:YES animated:YES];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"done-button"] forState:UIControlStateNormal];
        [self.editButton setFrame:CGRectMake(0, 0, 36, 13)];
    }
}

- (void)reloadHistoryView:(id)sender {
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return [self.locationModel.userLocations count];
    } else if ( section == 1 ) {
        return [self.locationModel.kmlLocations count];
    }
    return [self.locationModel.mapTileCollections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:@"Whitney-Book" size:19.f]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    NSString *title;
    BOOL showCoordinate;
    
    if ( indexPath.section == 0 ) {
        UserLocation *location = [self.locationModel.userLocations objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@ %@",location.title, location.subtitle];
        showCoordinate = [location.isVisible boolValue];
    } else if ( indexPath.section == 1 ) {
        KMLLocation *location = [self.locationModel.kmlLocations objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@", location.title];
        showCoordinate = [location.isVisible boolValue];
    } else {
        MapTileCollection *collection = [self.locationModel.mapTileCollections objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@", collection.title];
        showCoordinate = [collection.isVisible boolValue];
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
            return @"User locations";
        case 1:
            return @"Imported (KML) locations";
        case 2:
            return @"Map tiles";
        default:
            return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    [headerLabel setFont:[UIFont fontWithName:@"Whitney-Semibold" size:22]];
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
	headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
	[customView addSubview:headerLabel];
    
	return customView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
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
            UserLocation *userLocation = [self.locationModel.userLocations objectAtIndex:indexPath.row];
            [self.locationModel removeUserLocation:userLocation];
        } else if ( indexPath.section == 1 ) {
            KMLLocation *kmlLocation = [self.locationModel.kmlLocations objectAtIndex:indexPath.row];
            [self.locationModel removeKMLLocation:kmlLocation];
        } else {
            MapTileCollection *collection = [self.locationModel.mapTileCollections objectAtIndex:indexPath.row];
            [self.locationModel removeMapTileCollection:collection];
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ( indexPath.section == 0 ) {
        UserLocation *userLocation = [[self.locationModel userLocations] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.locationModel showUserLocation:userLocation];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self.locationModel hideUserLocation:userLocation];
        }        
    } else if ( indexPath.section == 1 ){
        KMLLocation *kmlLocation = [[self.locationModel kmlLocations] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.locationModel showKMLLocation:kmlLocation];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self.locationModel hideKMLLocation:kmlLocation];
        }
    } else {
        MapTileCollection *collection = [[self.locationModel mapTileCollections] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.locationModel showMapTileCollection:collection];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [self.locationModel hideMapTileCollection:collection];
        }
    }
    
}

//////////////////////////////////////////////////////////////
#pragma mark  - Getters and setters
//////////////////////////////////////////////////////////////



@end
