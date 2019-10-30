//
//  TKND.h
//  TKND for iOS
//
//  Created by  on 12/07/30.
//  Copyright (c) 2012 YoichiOnodera@tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/08/30	Yoichi Onodera	endcodeStringToPhp、decodeStringFromPhpを追加
//				12/09/14	Yoichi Onodera	checkStringAllSpacesを追加
//				12/09/26	Yoichi Onodera	getScreenSize、getScreenSizeNoStatusBarを追加
//											getScreenCenter、getScreenCenterNoStatusBarを追加
//				12/10/12	Yoichi Onodera	getScreenSizePortrait、getScreenSizeLandscapeを追加
//											getScreenSizeNoStatusBarPortrait、getScreenSizeNoStatusBarLandscapeを追加
//											getScreenCenterPortrait、getScreenCenterLandscapeを追加
//											getScreenCenterNoStatusBarBarPortrait、getScreenCenterNoStatusBarLandscapeを追加
//				12/11/06	Yoichi Onodera	iOSVersion、appVersion、hwMachine、deviceName、carrierNameを追加
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/types.h>
#import <sys/sysctl.h>

//	配列の要素数をカウントするマクロ(lengthがなく実態がある系)
#define COUNT_ARRAY(x)	(sizeof((x)) / sizeof((x)[0]))


@interface TKND : NSObject

//------------------------------------------------------------------------------
//	文字列操作系
//------------------------------------------------------------------------------
//	半角アスキー文字か判別する
+ (BOOL)checkCharacterHalfAscii:(NSString *)character;

//	半角カナ文字が判別する
+ (BOOL)checkCharacterkHalfKana:(NSString *)character;

//	指定された文字列が半角空白または全角空白のみで構成されていないか判別する
+ (BOOL)checkStringAllSpaces:(NSString *)string;

//	指定された文字数で半角全角を判別し指定されたlengthに収まるように調整した文字列を返す
+ (NSString *)adjustString:(NSString *)string length:(int)length;

//	URLエンコード文字列の'%'を'_'に変換(独自エンコード)する
+ (NSString *)encodeStringToPhp:(NSString *)string;

//	独自エンコード文字列の'_'を'%'に変換(URLエンコード)する
+ (NSString *)decodeStringFromPhp:(NSString *)string;

// twitter AuthDataからscreen_nameを取得
+ (NSString *)twitterUsernameFromAuthData;

+ (NSString*)uniqueID;


//------------------------------------------------------------------------------
//	サイズ取得系
//------------------------------------------------------------------------------
//	縦向き時の画面ザイズを取得する
+ (CGSize)getScreenSizePortrait;

//	横向き時の画面ザイズを取得する
+ (CGSize)getScreenSizeLandscape;

//	画面ザイズを取得する(過去互換用)
+ (CGSize)getScreenSize;

//	縦向き時のステータスバーを除いた画面ザイズを取得する
+ (CGSize)getScreenSizeNoStatusBarPortrait;

//	横向き時のステータスバーを除いた画面ザイズを取得する
+ (CGSize)getScreenSizeNoStatusBarLandscape;

//	ステータスバーを除いた画面ザイズを取得する(過去互換用)
+ (CGSize)getScreenSizeNoStatusBar;

//	縦向き時の画面の中心点を取得する
+ (CGPoint)getScreenCenterPortrait;

//	横向き時の画面の中心点を取得する
+ (CGPoint)getScreenCenterLandscape;

//	画面の中心点を取得する(過去互換用)
+ (CGPoint)getScreenCenter;

//	縦向き時のステータスバーを除いた画面の中心点を取得する
+ (CGPoint)getScreenCenterNoStatusBarPortrait;

//	横向き時のステータスバーを除いた画面の中心点を取得する
+ (CGPoint)getScreenCenterNoStatusBarLandscape;

//	ステータスバーを除いた画面の中心点を取得する(過去互換用)
+ (CGPoint)getScreenCenterNoStatusBar;


//------------------------------------------------------------------------------
//	各種固有文字列取得系
//------------------------------------------------------------------------------
//	iOSバージョン
+ (NSString *)iOSVersion;

//	アプリバージョン
+ (NSString *)appVersion;

//	ハードウェア機種名
+ (NSString *)hwMachine;

//	デバイス名
+ (NSString *)deviceName;

//	通信キャリア名
+ (NSString *)carrierName;

@end
