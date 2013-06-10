//
//  PrettyNavigationController.m
//  MyLupusScreens
//
//  Created by Nucleus on 24/09/2012.
//
//

#import "PrettyNavigationController.h"

@interface PrettyNavigationController ()

@end

@implementation PrettyNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureViews];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)configureViews
{
    PrettyNavigationBar *navBar = [[PrettyNavigationBar alloc] init];
    
//    navBar.topLineColor = rgb(163, 211, 156);
//    navBar.gradientStartColor = [UIColor colorWithHex:0x36af47];
//    navBar.gradientEndColor = [UIColor colorWithHex:0xd6c28];
//    
//    navBar.bottomLineColor = rgb(0, 100, 0);
//    navBar.tintColor = navBar.gradientEndColor;
//    navBar.roundedCornerRadius = 5;
    
    [self setValue:navBar forKeyPath:@"navigationBar"];
    
    PrettyToolbar *ptoolbar = [[PrettyToolbar alloc] init];
    
//    ptoolbar.topLineColor = rgb(100, 100, 100);
//    ptoolbar.gradientStartColor = rgb(100, 100, 100);
//    ptoolbar.gradientEndColor = rgb(60, 60, 60);
//    ptoolbar.bottomLineColor = rgb(30, 30, 30);
//    ptoolbar.tintColor = ptoolbar.gradientEndColor;
    
    [self setValue:ptoolbar forKey:@"toolbar"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
