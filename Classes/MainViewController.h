//
//  MainViewController.h
//  TouchNumber
//
//  Created by 鎌田 寛昭 on 09/05/13.
//  Copyright 株式会社寺島情報企画 2009. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/08/22	Yoichi Onodera		不正データの判定と送出防止対応
//												AdWhirlをGAdMob + mediationに差し替え
//				12/08/31	Yoichi Onodera		GAdMob + mediationをAdWhirlに差し戻す
//				12/12/14	Yoichi Onodera		広告切替えの変更対応(AdWhirl -> adfurikunsdk)
//												これにより各社広告SDKは廃止
//				12/12/18	Yoichi Onodera		GameCenter対応
//  ver3.18     13/06/11    Akihiko Sato        Replay Data Repost機能追加
//  ver3.20     13/07/01    Akihiko Sato        twitter frameworkの導入
//				YY/MM/DD	Name				Comment
//
#import <UIKit/UIKit.h>
#import "MainView.h"
#import "TKND.h"

#import "Social/Social.h"                       // Social設定
#import <Twitter/TWTweetComposeViewController.h>


@interface MainViewController : UIViewController
<
	GKLeaderboardViewControllerDelegate
>
{
	CGSize			screenSize;
	CGPoint			screenCenter;

	// ゲームセンター
	BOOL			isGameCenterOK;


    // Game Center
	IBOutlet UIButton *gamecenter_btn1;
	IBOutlet UIButton *gamecenter_btn2;
  

}
@property (nonatomic, strong) UIViewController	*mainViewController;
@property (nonatomic, strong) MainView			*mainView;

@end
