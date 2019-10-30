//
//  SettingsViewController.h
//  TouchNumber
//
//  Created by OnoHajime(Yoichi Onodera) on 12/04/24.
//  Copyright 2012 (株)テクノード. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/09/25	OnoHajime(Yoichi Onodera)	4インチ対応
//				YY/MM/DD	name						content
//

//----------------------------------------------
//	ヘッダ
//----------------------------------------------
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SettingsSecondViewController.h"
#import "TKND.h"


//----------------------------------------------
//	定数定義
//----------------------------------------------
static const NSString		*FILE_SETTINGS		= @"settings.dat";			// 設定ファイル名

static const NSString		*TRANING_MODE		= @"TRANING_MODE";			// トレーニングモードのOFF/ON用ID
static const NSString		*TRANING_SEC		= @"TRANING_SEC";			// トレーニングモードの秒数用ID
static const NSUInteger	TRANING_SEC_MIN		= SECOND_PICKER_MIN;		// トレーニングモードの最小秒数
static const NSUInteger	TRANING_SEC_MAX		= SECOND_PICKER_MAX;		// トレーニングモードの最大秒数

static const CGFloat		UI_ALPHA_DEFAULT	= 1.0f;						// UIControl群のアルファ値(標準)※MainViewにあわせる
static const CGFloat		UI_ALPHA_LIGHT		= 0.3f;						// UIControl群のアルファ値(グレー)※MainViewにあわせる

static const float			SCREEN_CENTER_V		= 160.0f;
static const float			SCREEN_CENTER_H		= 240.0f;
static const float			SCREEN_CENTER_H2	= 640.0f;


//----------------------------------------------
//	クラス定義
//----------------------------------------------
@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
@private
	IBOutlet UIButton						*traningModeCheckboxButton;			// トレーニングモードOFF/ONチェックボックス
	IBOutlet UIButton						*traningModeSecondButton;			// トレーニングモード秒ボタン
	IBOutlet UILabel						*automaticRestartInfoLabel;			// トレーニングモード秒設定説明用ラベル
	IBOutlet UILabel						*automaticRestartTimeLabel;			// トレーニングモード秒設定テキストフィールド用ラベル

	IBOutlet SettingsSecondViewController	*settingsSecondViewController;		// トレーニングモード秒設定サブビューコントローラー
    
    IBOutlet UIImageView *bgImageView;
    

//	IBOutlet UIView							*settingsSecondPickerView;

	NSInteger								traningModeSecond;					// トレーニングモード秒保持
	UIView									*coverView;							// SettingsSecondViewController実行時のカバー
}

//public:
- (BOOL)		getStatusTraningMode;											// 状態取得(0:OFF/1:ON)
- (NSUInteger)	getSecondTraningMode;											// 秒取得(1〜99)

//private:
- (IBAction)	touchTraningModeCheckboxButton:(UIButton *)sender;				// トレーニングモードOFF/ONチェックボックス通知処理
- (IBAction)	touchOkButton:(UIButton *)sender;								// トレーニングモードOKボタン通知処理
- (IBAction)	showSecondViewButton:(UIButton *)sender;						// トレーニングモード秒ボタン通知処理(秒設定サブビュー表示)

- (IBAction)	hideSecondViewButtonOk:(UIButton *)sender;						// 秒設定サブビューOKボタン処理
- (IBAction)	hideSecondViewButtonCancel:(UIButton *)sender;					// 秒設定サブビューCancelボタン処理

- (void)		refreshTraningModeUIControls;									// 状態によりUIControl群の状態変更

- (BOOL)		loadSettings;													// 設定ファイル入力
- (BOOL)		saveSettings:(int)mode;											// 設定ファイル出力
@end
