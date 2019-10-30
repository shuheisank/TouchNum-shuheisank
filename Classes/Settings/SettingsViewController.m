//
//  SettingsViewController.m
//  TouchNumber
//
//  Created by OnoHajime(Yoichi Onodera) on 12/04/24.
//  Copyright 2012 (株)テクノード. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/09/25	OnoHajime(Yoichi Onodera)	4インチ対応
//				YY/MM/DD	name						content
//

#import "SettingsViewController.h"

@interface SettingsViewController (private)
- (void)createCoverView;		// 連打防止カバーView生成
- (void)destroyCoverView;		// 連打防止カバーView破棄

@end



@implementation SettingsViewController

 #pragma mark - public:
 
//----------------------------------------------
// 練習モード設定秒数取得
//----------------------------------------------
- (NSUInteger)getSecondTraningMode {
LOG();

	NSInteger result = traningModeSecond;
	return result;
}


//----------------------------------------------
// 練習モードの状態取得
//----------------------------------------------
// TRUE:ON、FALSE:OFF
- (BOOL)getStatusTraningMode {
//LOG();	// ログおおすぎ

	BOOL result;

	if(traningModeCheckboxButton.tag) {
		result = TRUE;
	} else {
		result = FALSE;
	}
	return result;
}


#pragma mark - private:

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
LOG();

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if(self != nil) {
		// Custom initialization
	}
	return self;
}
*/


// インターフェイスビルダーのXIBが読み込み後の初期化の際に呼ばれる
- (id)initWithCoder:(NSCoder *)aDecoder {
LOG();

	if((self = [super initWithCoder:aDecoder])) {
		// カスタム初期化
	}
	return self;
}


/*
// This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
- (void)loadView {
LOG();

}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// 初回ロードされた時のみ呼び出される
- (void)viewDidLoad {
LOG();

	[super viewDidLoad];

	// 設定ファイル入力
	if([self loadSettings] == NO) {
		[self saveSettings:0];															// 設定ファイル作成
		[self loadSettings];															// 設定ファイル再入力
	}

	// UIControl群初期化
	[self refreshTraningModeUIControls];
    
    bgImageView.frame = CGRectMake(0, 0, 320, 480);
    bgImageView.alpha =1;
    //RankingBack0.png
}


// Called when the view is about to made visible. Default does nothing
// 画面が表示される都度呼び出される(iOS 4.3.1で呼ばれない)
-(void)viewWillAppear:(BOOL)animated {
LOG();

	[super viewWillAppear:animated];
}


// Called when the view has been fully transitioned onto the screen. Default does nothing
// 画面が表示された後に呼び出される
-(void)viewDidAppear:(BOOL)animated {
LOG();

	[super viewDidAppear:animated];
}


// Called when the view is dismissed, covered or otherwise hidden. Default does nothing
// 画面が閉じる前に呼び出される
-(void)viewWillDisappear:(BOOL)animated {
LOG();

	[super viewDidAppear:animated];
}


// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
// 画面が閉じた後に呼び出される(iOS4.3.1で呼ばれない)
-(void)viewDidDisappear:(BOOL)animated {
LOG();

	[super viewDidDisappear:animated];
}


// Called when the parent application receives a memory warning. Default implementation releases the view if it doesn't have a superview.
// メモリ不足時に呼び出される
- (void)didReceiveMemoryWarning {
LOG();

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}


// Called after the view controller's view is released and set to nil. For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// 画面がアンロードされたときに呼び出される
- (void)viewDidUnload {
LOG();

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
// 画面回転をするしないの設定
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
LOG();

}



//----------------------------------------------
// 練習モードチェックボックス通知処理
//----------------------------------------------
- (IBAction)touchTraningModeCheckboxButton:(UIButton *)sender {
LOG();

	if(sender.tag) {
		sender.tag = 0;
	} else {
		sender.tag = 1;
	}
	[self refreshTraningModeUIControls];
}


//----------------------------------------------
// 秒設定ボタン通知処理
//----------------------------------------------
- (IBAction)showSecondViewButton:(UIButton *)sender {
LOG();

	// アニメ設定

	// 初期座標設定
	CGSize screen = [TKND getScreenSize];
	settingsSecondViewController.view.frame = CGRectMake(
		0,
		screen.height + settingsSecondViewController.view.frame.size.height,
		settingsSecondViewController.view.frame.size.width,
		settingsSecondViewController.view.frame.size.height
	);

	// カバーの作成と追加
	[self createCoverView];
	coverView.alpha = 0.0f;

	// 秒ピッカーView追加
	[self.view addSubview:settingsSecondViewController.view];
	[settingsSecondViewController setSecond:traningModeSecond];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:nil];

	settingsSecondViewController.view.frame	= CGRectMake(
		0,
		screen.height - settingsSecondViewController.view.frame.size.height,
		settingsSecondViewController.view.frame.size.width,
		settingsSecondViewController.view.frame.size.height
	);
	coverView.alpha = 0.5f;
	[UIView commitAnimations];
}


//----------------------------------------------
//	秒設定サブViewOKボタン通知処理
//----------------------------------------------
- (IBAction)hideSecondViewButtonOk:(UIButton *)sender {
LOG();

	CGSize	screen	= [TKND getScreenSize];

	// アニメ設定
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(endAnimationHideSecondViewOk)];

	settingsSecondViewController.view.frame = CGRectMake(
		0,
		screen.height + settingsSecondViewController.view.frame.size.height,
		settingsSecondViewController.view.frame.size.width,
		settingsSecondViewController.view.frame.size.height
	);
	coverView.alpha = 0.0f;

	[UIView commitAnimations];
}


//----------------------------------------------
//	秒設定サブViewOKボタンアニメ後の処理
//----------------------------------------------
-(void)endAnimationHideSecondViewOk {
LOG();

	// カバーの破棄
	[self destroyCoverView];

	// 設定秒の取得
	traningModeSecond = [settingsSecondViewController getSecond];

	// 秒設定サブViewの取外し
	[settingsSecondViewController.view removeFromSuperview];

	// ボタンなどのアイテムの更新
	[self refreshTraningModeUIControls];
}


//----------------------------------------------
// 秒設定サブViewCancelボタン通知処理
//----------------------------------------------
- (IBAction)hideSecondViewButtonCancel:(UIButton *)sender {
LOG();

	// アニメ設定
	CGSize	screen	= [TKND getScreenSize];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(endAnimationHideSecondViewCancel)];

	settingsSecondViewController.view.frame = CGRectMake(
		0,
		screen.height + settingsSecondViewController.view.frame.size.height,
		settingsSecondViewController.view.frame.size.width,
		settingsSecondViewController.view.frame.size.height
	);
	coverView.alpha = 0.0f;

	[UIView commitAnimations];
}


//----------------------------------------------
// 秒設定サブViewCancelボタンアニメ後の通知処理
//----------------------------------------------
-(void)endAnimationHideSecondViewCancel {
LOG();

	// カバーの破棄
	[self destroyCoverView];

	// 秒設定サブViewの取外し(キャンセルなので秒の取得は行わない)
	[settingsSecondViewController.view removeFromSuperview];
}


//----------------------------------------------
// OKボタン通知処理
//----------------------------------------------
- (IBAction)touchOkButton:(UIButton *)sender {
LOG();

	// 設定ファイル出力
	[self saveSettings:1];
}


//----------------------------------------------
// 練習モードチェックボックスの表示状態更新
//----------------------------------------------
- (void)refreshTraningModeUIControls {
LOG();

	if(traningModeCheckboxButton.tag) {
		// ON
		[traningModeCheckboxButton setBackgroundImage:[UIImage imageNamed:@"CheckBox_C_w.png"] forState:UIControlStateNormal];
		automaticRestartInfoLabel.alpha	= UI_ALPHA_DEFAULT;				// Labelの色を標準に戻す(MainViewに合わせる)
		automaticRestartTimeLabel.alpha	= UI_ALPHA_DEFAULT;				// Labelの色を標準に戻す(MainViewに合わせる)
		traningModeSecondButton.alpha	= UI_ALPHA_DEFAULT;				// Labelの色を標準に戻す(MainViewに合わせる)
		traningModeSecondButton.enabled = YES;
    [traningModeSecondButton setTitle:[NSString stringWithFormat:@"%ld sec", (long)traningModeSecond] forState:UIControlStateNormal];
	} else {
		// OFF
		[traningModeCheckboxButton setBackgroundImage:[UIImage imageNamed:@"CheckBox_w.png"] forState:UIControlStateNormal];
		automaticRestartInfoLabel.alpha	= UI_ALPHA_LIGHT;				// Labelの色を灰色にする(MainViewに合わせる)
		automaticRestartTimeLabel.alpha	= UI_ALPHA_LIGHT;				// Labelの色を灰色にする(MainViewに合わせる)
		traningModeSecondButton.alpha	= UI_ALPHA_LIGHT;				// Labelの色を灰色にする(MainViewに合わせる)
		traningModeSecondButton.enabled = NO;
    [traningModeSecondButton setTitle:[NSString stringWithFormat:@"%ld sec", (long)traningModeSecond] forState:UIControlStateNormal];
	}
}


//----------------------------------------------
//	設定ファイル入力
//----------------------------------------------
//
- (BOOL)loadSettings {
LOG();

	NSArray				*paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString			*filepath	= [[paths objectAtIndex:0] stringByAppendingPathComponent:(NSString *)FILE_SETTINGS];
	NSMutableDictionary	*dictionary	= [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
	BOOL				result		= NO;

	if(dictionary != nil) {
		// UIControl初期化
		traningModeCheckboxButton.tag	= [[dictionary objectForKey:TRANING_MODE] intValue];
		traningModeSecond				= [[dictionary objectForKey:TRANING_SEC] intValue];
		result							= YES;
	}
	return result;
}


//----------------------------------------------
//	設定ファイル出力
//----------------------------------------------
// 0:初期値、!0:保持値
- (BOOL)saveSettings:(int)mode {
LOG();

	NSArray				*paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString			*filepath	= [[paths objectAtIndex:0] stringByAppendingPathComponent:(NSString *)FILE_SETTINGS];
	NSMutableDictionary	*dictionary	= [NSMutableDictionary dictionary];
	BOOL				result		= YES;

	if(mode == 0) {
		// 初期値
		[dictionary setObject:[NSString stringWithFormat:@"%d", 0] forKey:TRANING_MODE];
    [dictionary setObject:[NSString stringWithFormat:@"%lu", (unsigned long)TRANING_SEC_MAX] forKey:TRANING_SEC];
	} else {
		// 保持値
		[dictionary setObject:[NSString stringWithFormat:@"%d", [self getStatusTraningMode]] forKey:TRANING_MODE];
    [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)traningModeSecond] forKey:TRANING_SEC];
	}
	// ファイル出力
	[dictionary writeToFile:filepath atomically:YES];
	return result;
}

//------------------------------------------------------------------------------
//	rankingView表示時のカバーViewの作成
//------------------------------------------------------------------------------
- (void)createCoverView {
LOG();

	CGSize	screen = [TKND getScreenSize];
	CGRect	rect;

	rect.origin.x		= 0.0f;
	rect.origin.y		= 0.0f;
	rect.size.width		= screen.width;
	rect.size.height	= screen.height;

	coverView					= [[UIAlertView alloc] initWithFrame:rect];
	coverView.backgroundColor	= [UIColor blackColor];

	[self.view addSubview:coverView];
}


//------------------------------------------------------------------------------
//	rankingView表示時のカバーViewの削除
//------------------------------------------------------------------------------
- (void)destroyCoverView {
LOG();

	[coverView removeFromSuperview];
	coverView = nil;
}


@end
