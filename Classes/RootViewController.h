//
//  RootViewController.h
//  TouchNumber
//
//  Created by 鎌田 寛昭 on 09/05/13.
//  Copyright 株式会社寺島情報企画 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController {

	UIButton				*infoButton;
	MainViewController		*mainViewController;
	FlipsideViewController	*flipsideViewController;
	UINavigationBar			*flipsideNavigationBar;
}

@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;

//- (IBAction)toggleView;

@end
