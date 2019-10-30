//
//  RootViewController.m
//  TouchNumber
//
//  Created by 鎌田 寛昭 on 09/05/13.
//  Copyright 株式会社寺島情報企画 2009. All rights reserved.
//

#import "RootViewController.h"
//	#import "MainViewController.h"
#import "FlipsideViewController.h"


@interface RootViewController()
- (BOOL)gameCenterAvailable;
- (void)gameCenterAuthenticateLocalPlayer;
@end


@implementation RootViewController

@synthesize infoButton;
@synthesize flipsideNavigationBar;
@synthesize mainViewController;
@synthesize flipsideViewController;


- (void)viewDidLoad {
LOG();

	[super viewDidLoad];

//	MainViewController *viewController	= [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
//	self.mainViewController				= viewController;
//	[viewController release];

//	[self.view insertSubview:mainViewController.view belowSubview:infoButton];
}

#if 0
- (void)loadFlipsideViewController {
LOG();

	FlipsideViewController *viewController	= [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	self.flipsideViewController				= viewController;
	[viewController release];

	// Set up the navigation bar
	UINavigationBar *aNavigationBar	= [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	aNavigationBar.barStyle			= UIBarStyleBlackOpaque;
	self.flipsideNavigationBar		= aNavigationBar;
	[aNavigationBar release];

	UIBarButtonItem *buttonItem			= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleView)];
	UINavigationItem *navigationItem	= [[UINavigationItem alloc] initWithTitle:@"Touch The Numbers"];
	navigationItem.rightBarButtonItem	= buttonItem;
	[flipsideNavigationBar pushNavigationItem:navigationItem animated:NO];
	[navigationItem release];
	[buttonItem release];
}



- (IBAction)toggleView {
LOG();
	/*
	 This method is called when the info or Done button is pressed.
	 It flips the displayed view from the main view to the flipside view and vice-versa.
	 */
	if (flipsideViewController == nil) {
		[self loadFlipsideViewController];
	}

	UIView *mainView = mainViewController.view;
	UIView *flipsideView = flipsideViewController.view;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];

	if ([mainView superview] != nil) {
		[flipsideViewController viewWillAppear:YES];
		[mainViewController viewWillDisappear:YES];
		[mainView removeFromSuperview];
		[infoButton removeFromSuperview];
		[self.view addSubview:flipsideView];
		[self.view insertSubview:flipsideNavigationBar aboveSubview:flipsideView];
		[mainViewController viewDidDisappear:YES];
		[flipsideViewController viewDidAppear:YES];

	} else {
		[mainViewController viewWillAppear:YES];
		[flipsideViewController viewWillDisappear:YES];
		[flipsideView removeFromSuperview];
		[flipsideNavigationBar removeFromSuperview];
		[self.view addSubview:mainView];
		[self.view insertSubview:infoButton aboveSubview:mainViewController.view];
		[flipsideViewController viewDidDisappear:YES];
		[mainViewController viewDidAppear:YES];
	}
	[UIView commitAnimations];
}
#endif



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
LOG();

	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
LOG();

	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
LOG();

	[infoButton release];
	[flipsideNavigationBar release];
	[mainViewController release];
	[flipsideViewController release];
	[super dealloc];
}

@end