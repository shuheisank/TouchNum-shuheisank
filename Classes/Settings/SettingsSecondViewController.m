//
//  SettingsSecondViewController.m
//  TouchNumber
//
//  Created by OnoHajime(Yoichi Onodera) on 12/04/24.
//  Copyright 2012 (株)テクノード. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/09/25	OnoHajime(Yoichi Onodera)	4インチ対応
//				YY/MM/DD	name						content
//

#import "SettingsSecondViewController.h"
#import "TKND.h"


@implementation SettingsSecondViewController

# pragma mark - public methods

//----------------------------------------------
// ピッカーに表示する秒を設定する
//----------------------------------------------
- (void)setSecond:(NSInteger)sec {
LOG();

	[secondPicker selectRow:(sec - 1) inComponent:0 animated:YES];
}


//----------------------------------------------
// ピッカーの現在選択されている秒を取得する
//----------------------------------------------
- (NSInteger)getSecond {
LOG();

	NSInteger	result = [secondPicker selectedRowInComponent:0] + SECOND_PICKER_MIN;
	return result;
}




#pragma mark - private function

//----------------------------------------------
// 初期化
//----------------------------------------------
- (void)viewDidLoad {
LOG();

	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
}


//----------------------------------------------
// [必須]ピッカーに表示する列数を設定する
//----------------------------------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
LOG();

	NSInteger result = SECOND_PICKER_COLUMN;
	return result;
}


//----------------------------------------------
// [必須]ピッカーに表示する行数を設定する
//----------------------------------------------
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
LOG();

	NSInteger result = SECOND_PICKER_ROWS;
	return result;
}


//----------------------------------------------
// ピッカーの幅を設定する
//----------------------------------------------
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
LOG();

	CGFloat result = SECOND_PICKER_WIDTH;
	return result;
}


//----------------------------------------------
// ピッカーの行の高さを設定する
// ※高さ自体は変更できないようだ
//----------------------------------------------
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
LOG();

	CGFloat result = SECOND_PICKER_ROW_HEIGHT;
	return result;
}


//----------------------------------------------
// 表示する内容を返す例
//----------------------------------------------
-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//LOG();	//ログおおすぎ

	// rowが0番〜98番までのインデックスが来るので、それ + SECOND_PICKER_MINを表示用文字列とする
  NSString *result = [NSString stringWithFormat:@"%d", row + SECOND_PICKER_MIN];
	return result;
}

@end

