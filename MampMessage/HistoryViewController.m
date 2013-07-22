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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"[HVC] viewWillAppear");
    
    [self.tableView reloadData];
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
    
//    [self.tableView addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewDidUnload {
    
    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    self.editButton = nil;
    
    [super viewDidUnload];
}

- (void)toggleEditingMode {
    NSLog(@"[HVC] Toggle editing");
    
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
        return [self.locationModel.userLocations count];
    } else if ( section == 1 ) {
        return [self.locationModel.mapTileCollections count];
    }
    //        return [self.locationModel.kmlLocations count];
    //    }
    
    return 0;
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
    BOOL showCoordinate = NO;
    
    if ( indexPath.section == 0 ) {
        UserLocation *location = [self.locationModel.userLocations objectAtIndex:indexPath.row];
        
        title = [NSString stringWithFormat:@"%@ %@",location.title, location.subtitle];
        showCoordinate = [location.selected boolValue];
        
    } else if ( indexPath.section == 1 ) {
        MapTileCollection *collection = [self.locationModel.mapTileCollections objectAtIndex:indexPath.row];
        title = [NSString stringWithFormat:@"%@", collection.title];
        showCoordinate = [collection.isVisible boolValue];
    }
    
    cell.textLabel.text = title;
    
    if ( showCoordinate == YES ) {
        
        if ( indexPath.section == 0 ) {
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation-view-menu"]]];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    } else {
        if ( indexPath.section == 0 ) {
            [cell setAccessoryView:nil];
        } else {
            [cell setAccessoryView:nil];
        }
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"User locations";
        case 1:
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 1 ) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        if ( indexPath.section == 0 ) {
            UserLocation *userLocation = [self.locationModel.userLocations objectAtIndex:indexPath.row];
            [self.delegate deleteSelectedAnnotation:(id)userLocation];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}


//////////////////////////////////////////////////////////////
#pragma mark  - UITableViewDelegate methods
//////////////////////////////////////////////////////////////

- (void)unsetPreviousDestination
{
    UITableViewCell *previousDestinationCell;
    Location *currentDestination = self.locationModel.currentDestination;
    
    if ( [currentDestination isKindOfClass:[UserLocation class]] ) {
        NSInteger index = [self.locationModel.userLocations indexOfObject:currentDestination];
        previousDestinationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    } else if ( [currentDestination isKindOfClass:[KMLLocation class]] ) {
        NSInteger index = [self.locationModel.kmlLocations indexOfObject:currentDestination];
        previousDestinationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    }
    
    [self.delegate setDestination:nil];
    [previousDestinationCell setAccessoryView:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //We're about to unset the previous destination, so save the title for comparison
    NSString *currentDestinationTitle = self.locationModel.currentDestination.title;
    
    if ( self.locationModel.currentDestination ) {
        [self unsetPreviousDestination];
    }
    
    if ( indexPath.section == 0 ) {
        UserLocation *userLocation = [[self.locationModel userLocations] objectAtIndex:indexPath.row];
        
        if ( ![userLocation.title isEqualToString:currentDestinationTitle] ) {
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation-view-menu"]]];
            [self.delegate setDestination:userLocation];
        } 
    } else if ( indexPath.section == 1 ){
        MapTileCollection *collection = [[self.locationModel mapTileCollections] objectAtIndex:indexPath.row];
        
        if ( cell.accessoryType == UITableViewCellAccessoryNone ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [self.delegate showMapTileCollection:collection];
        } else {
            [self.delegate hideMapTileCollection:collection];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }

    [self.slidingViewController resetTopView];
}

//////////////////////////////////////////////////////////////
#pragma mark  - UIGestureRecogniserDelegate methods
//////////////////////////////////////////////////////////////



@end
