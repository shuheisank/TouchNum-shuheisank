//
//  SettingsSecondViewController.h
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


//----------------------------------------------
//	定数定義
//----------------------------------------------
static const NSInteger SECOND_PICKER_WIDTH		= 80.0f;						// ピッカーの幅
static const NSInteger SECOND_PICKER_ROW_HEIGHT	= 40.0f;						// ピッカーの行の高さ
static const NSInteger SECOND_PICKER_COLUMN		= 1;							// ピッカーの列数
static const NSInteger SECOND_PICKER_ROWS			= 99;							// ピッカーの行数

static const NSInteger SECOND_PICKER_MIN			= 1;							// ピッカーの最小値(0始まりのオフセット)
static const NSInteger SECOND_PICKER_MAX			= SECOND_PICKER_ROWS;			// ピッカーの最大値


//----------------------------------------------
//	クラス定義
//----------------------------------------------
@interface SettingsSecondViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
@private
	IBOutlet UIPickerView	*secondPicker;
}

//public:
-(void)			setSecond:(NSInteger)sec;										// ピッカーの初期選択位置(秒)を設定する
-(NSInteger)	getSecond;														// ピッカーの現在の選択位置(秒)を取得する
@end