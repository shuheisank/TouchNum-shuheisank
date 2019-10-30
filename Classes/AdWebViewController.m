//
//  AdWebViewController.m
//  TouchNumber
//
//  Created by  on 12/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/10/31	Yoichi Onodera		iOS4.3系でtekunodo.ウェブが表示されない不具合修正
//												viewWillAppearの処理を分離 > initAdWebViewを追加
//												Toolbarが機能していないので修正
//				YY/MM/DD	Name				Comment
//

#import "AdWebViewController.h"


//------------------------------------------------------------------------------
@interface AdWebViewController (Private)
- (void)_setButtonEnabled;
@end


//------------------------------------------------------------------------------
@implementation AdWebViewController
@synthesize url = _url;
@synthesize navigationTitle = _navigationTitle;


//------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
LOG();

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		// Custom initialization
	}
	return self;
}


//------------------------------------------------------------------------------
- (id)initWithURL:(NSURL *)url {
LOG();

	self = [super initWithNibName:@"AdWebViewController" bundle:nil];

	if (self) {
		self.url = url;
	}

	return self;
}


//------------------------------------------------------------------------------
- (void)initAdWebView {
LOG();

	NSURLRequest *request	= [NSURLRequest requestWithURL:self.url];

	// Toolbar
	toolBar.frame = CGRectMake(0.0f, screenSize.height - toolBar.frame.size.height, screenSize.width, toolBar.frame.size.height);

	// indicator
	indicator.frame = CGRectMake(
		indicator.frame.origin.x,
		screenSize.height - toolBar.frame.size.height + (toolBar.frame.size.height - indicator.frame.size.height) / 2,
		indicator.frame.size.width,
		indicator.frame.size.height
	);

	// WebView
	webView = [
		[UIWebView alloc]
		initWithFrame:CGRectMake(
			0.0f,
			navigationBar.frame.size.height,
			screenSize.width,
			screenSize.height - navigationBar.frame.size.height - toolBar.frame.size.height
		)
	];
	webView.delegate		= self;
	webView.scalesPageToFit	= YES;
	[self.view addSubview:webView];

//	[self.view bringSubviewToFront:indicator];

	[webView loadRequest:request];
}


//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
LOG();

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}


//------------------------------------------------------------------------------
- (void)dealloc {
LOG();

	self.navigationTitle=nil;
	self.url=nil;
}


// =============================================================================
#pragma mark - View lifecycle

//------------------------------------------------------------------------------
- (void)viewDidLoad {
LOG();

	[super viewDidLoad];

	screenSize		= [TKND getScreenSizePortrait];
	screenCenter	= [TKND getScreenCenterPortrait];

	// toolbarのボタンたちを作る
	back						= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:101 target:self action:@selector(pageBack)];
	back.enabled				= NO;

	UIBarButtonItem *space		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	space.width					= 40.0f;

	fwd							= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:102 target:self action:@selector(pageForward)];
	fwd.enabled					= NO;

	UIBarButtonItem *reload		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pageReload)];
	toolBar.items				= [NSArray arrayWithObjects:back, space, fwd, space, reload, nil];

}


//------------------------------------------------------------------------------
- (void)viewDidUnload {
LOG();

	[super viewDidUnload];
}


//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
LOG();

	[super viewWillAppear:animated];
/*
	NSURLRequest *request		= [NSURLRequest requestWithURL:self.url];
	webView						= [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 392.0f)];
	webView.delegate			= self;
	webView.scalesPageToFit		= YES;
	[self.view addSubview:webView];
	[webView loadRequest:request];
*/
}


//------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated {
LOG();

	[super viewDidDisappear:animated];
	webView = nil;
}


//------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
LOG();

	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//------------------------------------------------------------------------------
- (void)pageBack {
LOG();

	[webView goBack];
}


//------------------------------------------------------------------------------
- (void)pageForward {
LOG();

	[webView goForward];
}


//------------------------------------------------------------------------------
- (void)pageReload {
LOG();

	[webView reload];
}


//------------------------------------------------------------------------------
- (void)_setButtonEnabled {
LOG();

	back.enabled	= [webView canGoBack];
	fwd.enabled		= [webView canGoForward];
}


// =============================================================================
#pragma mark - UIWebViewDelegate

//------------------------------------------------------------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView_ {
LOG();

	indicator.hidden = NO;
	[indicator startAnimating];
}


//------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
LOG();

	[indicator stopAnimating];
	indicator.hidden = YES;
	[self _setButtonEnabled];
}


//------------------------------------------------------------------------------
- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
LOG();

	[self webViewDidFinishLoad:webView_];
}

@end
