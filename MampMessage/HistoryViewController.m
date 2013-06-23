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
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 25, 13)];
    [self.editButton addTarget:self action:@selector(toggleEditingMode) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"edit-button"] forState:UIControlStateNormal];
    [self setEditing:NO animated:NO];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    
    self.navigationItem.leftBarButtonItem = editBarButtonItem;
    [self.navigationItem setTitle:@"Locations"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistoryView:) name:BZCoordinateDataChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"Saving context...");
    
    [self.locationModel saveContext];
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
        showCoordinate = [location.selected boolValue];
        
        if (showCoordinate) {
            [self.locationModel setDestination:location];
        }
        
    } else if ( indexPath.section == 1 ) {
        KMLLocation *location = [self.locationModel.kmlLocations objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@", location.title];
        showCoordinate = [location.selected boolValue];
        
        if ( showCoordinate ) {
            [self.locationModel setDestination:location];
        }
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
	headerLabel.backgroundColor = [UIColor whiteColor];
	headerLabel.opaque = YES;
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    [headerLabel setFont:[UIFont fontWithName:@"Whitney-Semibold" size:22]];
    
    UIButton * infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton setCenter:CGPointMake(320, 10)];
        
	headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
	[customView addSubview:headerLabel];
    [customView addSubview:infoButton];
    
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
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
            [self.locationModel setDestination:userLocation];
        } else if ( cell.accessoryType == UITableViewCellAccessoryCheckmark ) {
            [self.locationModel setDestination:nil];
        }
        [self.tableView reloadData];
    } else if ( indexPath.section == 1 ){
        KMLLocation *kmlLocation = [[self.locationModel kmlLocations] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [self.locationModel setDestination:kmlLocation];
        } else if ( cell.accessoryType == UITableViewCellAccessoryCheckmark ) {
            [self.locationModel setDestination:nil];
        }
        [self.tableView reloadData];
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
