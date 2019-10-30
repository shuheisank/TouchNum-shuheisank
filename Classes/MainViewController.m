//
//  MainViewController.m
//  TouchNumber
//
//  Created by 鎌田 寛昭 on 09/05/13.
//  Copyright 株式会社寺島情報企画 2009. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/08/22	Yoichi Onodera		不正データの判定と送出防止対応
//												AdWhirlをGAdMob + mediationに差し替え
//				12/08/31	Yoichi Onodera		GAdMob + mediationをAdWhirlに差し戻す
//				12/09/25	Yoichi Onodera		4インチ対応
//				12/12/14	Yoichi Onodera		広告切替えの変更対応(AdWhirl -> adfurikunsdk)
//												これにより各社広告SDKは廃止
//				12/12/18	Yoichi Onodera		GameCenter対応
//  ver3.18     13/06/11    Akihiko Sato        Replay Data Repost機能追加
//  ver3.20     13/07/01    Akihiko Sato        twitter frameworkの導入
//				12/XX/XX	Name				Comment
//

#import "MainViewController.h"
#import "TKND.h"

#import "NetworkAvailable.h"

@interface MainViewController()
- (BOOL)gameCenterAvailable;
- (void)gameCenterAuthenticateLocalPlayer;
- (void)gameCenterShowReaderBoard;
- (void)gameCenterShowReaderBoard2;
@end


@implementation MainViewController

@synthesize mainViewController;
@synthesize mainView;

#pragma mark - Private
//------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
LOG();

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if(self != nil) {
		// Custom initialization
		screenSize		= [TKND getScreenSizePortrait];
		screenCenter	= [TKND getScreenCenterPortrait];
		self.mainView	= (MainView *)self.view;
	}
  
  if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
    LOG(@"iPad");
    self.mainView.transform = CGAffineTransformMakeScale(2, 2);
    CGSize s_ = self.mainView.frame.size;
    self.mainView.frame = CGRectMake(0, 0, s_.width/2, s_.height/2);
  }
  
	return self;
}


//------------------------------------------------------------------------------
//	Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//------------------------------------------------------------------------------
- (void)viewDidLoad {
//LOG();

	[super viewDidLoad];
	
	// analytics
//  tracker = [[GAI sharedInstance] defaultTracker];

	mainView = (MainView *)self.view;
	LOG(@"%@", mainView);

	// ゲームセンターは使用可能か
	//--------------------------------------------------------------------------
	isGameCenterOK	= [self gameCenterAvailable];
	LOG(@"GameCenter:%d", isGameCenterOK);

	if(isGameCenterOK == YES) {
		[self gameCenterAuthenticateLocalPlayer];
		
		//---------------------------------------
		//leaderboardを調べる
		//---------------------------------------
		//[self loadLeaderboardInfo];
		
	} else {
		LOG(@"GameCenter disable");
		//---------------------------------------
		//ゲームセンター未対応の場合、非表示にする
		//---------------------------------------
		gamecenter_btn1.hidden = YES;
		gamecenter_btn2.hidden = YES;
	}

	
	//--------------------------------------------------------------------------
	// twitterダイアログの呼び出し ver3.20
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTwitterDialog:)
                                                 name:@"showTwitterDialog"
                                               object:nil];
	

}


/*
//------------------------------------------------------------------------------
// Override to allow orientations other than the default portrait orientation.
//------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
LOG();

	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
LOG();

	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


//------------------------------------------------------------------------------
- (void)viewDidUnload {
LOG();

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	gamecenter_btn1 = nil;
	gamecenter_btn2 = nil;
	[super viewDidUnload];
}


//------------------------------------------------------------------------------
- (void)dealloc {
LOG();

//  if(FREE_FLAG) {
//    // アドフリくん解放
//    if(adfurikunView != nil) {
//      //adfurikunView.adfurikunDelegate = nil;
//            adfurikunView.delegate = nil;
//    }
//  }
}


//==============================================================================
#pragma mark - Button

//------------------------------------------------------------------------------
- (IBAction)touchGameCenterButton:(UIButton *)sender {
LOG();

	[self gameCenterShowReaderBoard];  //numberの呼び出し
}

- (IBAction)touchGameCenterButton2:(UIButton *)sender {
LOG();
	
	[self gameCenterShowReaderBoard2];  //scoreの呼び出し
}

// AdfurikunInterstitial
- (IBAction)touchMoreApps:(UIButton *)sender {

//  [self.view addSubview:adfurikunPopupView];
//    [adfurikunPopupView startShowAd];
}


//==============================================================================
#pragma mark - Game Center

//------------------------------------------------------------------------------
//	ゲームセンターは使用可能か確認
//------------------------------------------------------------------------------
- (BOOL)gameCenterAvailable {
LOG();

	// Check for presence of GKLocalPlayer API.
	Class		gcClass				= NSClassFromString(@"GKLocalPlayer");

	// The device must be running running iOS 4.1 or later.
	NSString	*reqSysVer			= @"4.1";
	NSString	*currSysVer			= [[UIDevice currentDevice] systemVersion];
	BOOL		osVersionSupported	= ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	BOOL		result				= gcClass && osVersionSupported;
	

	
	return result;
}
//------------------------------------------------------------------------------
//	Leaderboardを調べる
//------------------------------------------------------------------------------
- (void) loadLeaderboardInfo
{
/*
	LOG(@"============ %s",__FUNCTION__);
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
		for (GKLeaderboard *leaderboard in leaderboards) {
			LOG(@"%@",leaderboards);
			LOG(@"title:%@ category:%@",leaderboard.title,leaderboard.category);
		}
       // self.leaderboards = leaderboards;
		
	}];
*/ 
}

//------------------------------------------------------------------------------
//	ゲームセンターのプレイヤー名取得
//------------------------------------------------------------------------------
- (void)gameCenterAuthenticateLocalPlayer {
LOG();

	[	[GKLocalPlayer localPlayer]
		authenticateWithCompletionHandler:^(NSError *error) {
			if(error == nil) {
				 // Insert code here to handle a successful authentication.(認証成功)
				[gamecenter_btn1 setEnabled:YES];
				[gamecenter_btn2 setEnabled:YES];
				
			} else {
				 // Your application can process the error parameter to report the error to the player.(認証失敗)
				LOG(@"%@", [error localizedDescription]);
				// 認証出来なかったら、GameCenterボタンは使用不可
				[gamecenter_btn1 setEnabled:NO];
				[gamecenter_btn2 setEnabled:NO];
				
			}
		}
	];
}


//------------------------------------------------------------------------------
//	ゲームセンターのリーダーボード表示
//------------------------------------------------------------------------------
- (void)gameCenterShowReaderBoard {
LOG();

	GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];

	if (leaderboardViewController != NULL) {
		
		leaderboardViewController.category				= GAME_CENTER_PLAY_COUNT;	// その日のプレイ回数
		//leaderboardViewController.category			= GAME_CENTER_PLAY_SCORE;	// スコア(ランキングのTotalと同様)
		LOG(@"%@",leaderboardViewController.category);
		leaderboardViewController.timeScope				= GKLeaderboardTimeScopeToday;
		leaderboardViewController.leaderboardDelegate	= self;
		[self presentModalViewController:leaderboardViewController animated:YES];
	}
	
	// analytics
//  [tracker trackView:@"/leaderboard_count"];
}

- (void)gameCenterShowReaderBoard2 {
	LOG();

	GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
	
	if (leaderboardViewController != NULL) {
		//leaderboardViewController.category			= GAME_CENTER_PLAY_COUNT;	// その日のプレイ回数
		leaderboardViewController.category				= GAME_CENTER_PLAY_SCORE;	// スコア(ランキングのTotalと同様)
		LOG(@"%@",leaderboardViewController.category);
		leaderboardViewController.timeScope				= GKLeaderboardTimeScopeToday;
		leaderboardViewController.leaderboardDelegate	= self;
		[self presentModalViewController:leaderboardViewController animated:YES];
	}
	
	// analytics
//  [tracker trackView:@"/leaderboard_score"];
}

//==============================================================================
#pragma mark - Leader Board Delegate

//------------------------------------------------------------------------------
//	リーダーボードの完了ボタンがが押下された
//------------------------------------------------------------------------------
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
LOG();
	
	// リーダーボードを非表示にする
	[self dismissModalViewControllerAnimated:YES];
	
	// analytics
//  [tracker trackView:@"/top"];
}
//==============================================================================
#pragma mark - twitter
//------------------------------------------------------------------------------
-(void)showTwitterDialog:(NSNotification *)notification{
	LOG();
	NSString *message = [[notification userInfo] objectForKey:@"TwitterMessage"];
	
	//----------------------------------------------------------
	// iOS6以上はSocial.frameworkを使う
	Class flagiOS6 = NSClassFromString(@"SLComposeViewController");
	//----------------------------------------------------------
	
	if(flagiOS6){
		// twitter iOS6 ~
		SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[controller setInitialText:message];
		[controller addImage:[UIImage imageNamed:@"icon"]];
		
		[self presentViewController:controller animated:YES completion:nil];
		
	} else {
		// twitter iOS5
		TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
		[tweetViewController setInitialText:message];
		[tweetViewController addImage:[UIImage imageNamed:@"icon"]];
		
		[self presentModalViewController:tweetViewController animated:YES];
	}
	
}

//==============================================================================
#if(FREE_FLAG == 1)
#pragma mark - AdfurikunViewDelegate
//
////------------------------------------------------------------------------------
//- (void)adfurikunViewDidFinishLoad:(AdfurikunView *)view {
//LOG(@"adfurikun: ad loaded");
//
//}
//
//
////------------------------------------------------------------------------------
//- (void)adfurikunViewAdTapped:(AdfurikunView *)view {
//LOG(@"adfurikun: ad clicked");
//
//}
#endif



@end
