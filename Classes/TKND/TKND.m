//
//  TKND.m
//  TKND for iOS
//
//  Created by  on 12/07/30.
//  Copyright (c) 2012 YoichiOnodera@tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/08/30	Yoichi Onodera	endcodeStringToPhp、decodeStringFromPhpを追加
//				12/09/04	Yoichi Onodera	adjustStringを修正
//				12/09/07	Yoichi Onodera	adjustString、encodeStringToPhp、decodeStringFromPhpを修正
//				12/09/14	Yoichi Onodera	checkStringAllSpacesを追加
//				12/09/26	Yoichi Onodera	getScreenSize、getScreenSizeNoStatusBarを追加
//											getScreenCenter、getScreenCenterNoStatusBarを追加
//				12/10/12	Yoichi Onodera	getScreenSizePortrait、getScreenSizeLandscapeを追加
//											getScreenSizeNoStatusBarPortrait、getScreenSizeNoStatusBarLandscapeを追加
//											getScreenCenterPortrait、getScreenCenterLandscapeを追加
//											getScreenCenterNoStatusBarBarPortrait、getScreenCenterNoStatusBarLandscapeを追加
//				12/11/06	Yoichi Onodera	iOSVersion、appVersion、hwMachine、deviceName、carrierNameを追加
//

#import "TKND.h"
#import "NetworkAvailable.h"

//#define TKND_DEBUG

@implementation TKND


#pragma mark - String

//------------------------------------------------------------------------------
//	半角アスキー文字か判別する
//------------------------------------------------------------------------------
+ (BOOL)checkCharacterHalfAscii:(NSString *)character {
#ifdef TKND_DEBUG
	NSLog(@"%s:%@", __FUNCTION__, character);
#endif

	NSRange	match	= [character rangeOfString:@"[ -~]" options:NSRegularExpressionSearch];
	BOOL	result	= NO;

	if(match.location != NSNotFound) {
		result = YES;
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%d", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	半角ｶﾅ文字か判別する
//------------------------------------------------------------------------------
+ (BOOL)checkCharacterkHalfKana:(NSString *)character {
#ifdef TKND_DEBUG
	NSLog(@"%s character:%@", __FUNCTION__, character);
#endif

	NSRange	match	= [character rangeOfString:@"[｡-ﾟ]" options:NSRegularExpressionSearch];
	BOOL	result	= NO;

	if(match.location != NSNotFound) {
		result = YES;
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%d", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	指定された文字列が半角空白または全角空白のみで構成されていないか判別する
//------------------------------------------------------------------------------
+ (BOOL)checkStringAllSpaces:(NSString *)string {
#ifdef TKND_DEBUG
	NSLog(@"%s string:%@", __FUNCTION__, string);
#endif

	BOOL result = NO;

	for(int i = 0; i < [string length];) {
		NSRange		range		= [string rangeOfComposedCharacterSequenceAtIndex:i];
		NSString	*character	= [string substringWithRange:NSMakeRange(i, range.length)];
		i += range.length;

		if([character isEqualToString:@" "] == NO && [character isEqualToString:@"　"] == NO) {
			result = YES;
			break;
		}
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%d", __FUNCTION__, result);
#endif
	return result;
}

//------------------------------------------------------------------------------
//	指定された文字数で半角全角を判別し指定されたlengthに収まるように調整した文字列を返す
//------------------------------------------------------------------------------
+ (NSString *)adjustString:(NSString *)string length:(int)length {
#ifdef TKND_DEBUG
	NSLog(@"%s string:%@, length:%d", __FUNCTION__, string, length);
#endif

	NSMutableString *result	= [[NSMutableString alloc] init];
	int				count	= 0;

	for(int i = 0; i < [string length];) {
		NSRange		range		= [string rangeOfComposedCharacterSequenceAtIndex:i];
		NSString	*character	= [string substringWithRange:NSMakeRange(i, range.length)];
		i += range.length;

#ifdef TKND_DEBUG
		NSLog(@"[JOB]%s:%d, Length:%d, character:%@", __FUNCTION__, range.location, range.length, character);
#endif

		// iOSはUTF8であり半角カナがマルチバイトとして扱われるが1バイトとして扱う
		if([self checkCharacterkHalfKana:character] == YES) {
			count++;	// 半角
		} else if([self checkCharacterHalfAscii:character] == NO) {
			count += 2;	// 全角
		} else {
			count++;	// 半角
		}

		if(count > length) {
			break;
		}
		// 返却する文字列を作成
		[result appendString:character];
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%@", __FUNCTION__, result);
#endif
	return result;
}


#pragma mark - Encode

//------------------------------------------------------------------------------
//	URLエンコード文字列の'%'を'_'に変換(独自エンコード)する
//------------------------------------------------------------------------------
+ (NSString *)encodeStringToPhp:(NSString *)string {
#ifdef TKND_DEBUG
	NSLog(@"%s string:%@", __FUNCTION__, string);
#endif

	NSMutableString *result	= [[NSMutableString alloc] init];

	for(int i = 0; i < [string length]; i++) {
		NSString *character = [string substringWithRange:NSMakeRange(i, 1)];

		if([character isEqualToString:@"%"] == YES) {
			[result appendString:@"_"];
		} else {
			[result appendString:character];
		}
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%@", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	独自エンコード文字列の'%'を'_'に変換(URLエンコード)する
//------------------------------------------------------------------------------
+ (NSString *)decodeStringFromPhp:(NSString *)string {
#ifdef TKND_DEBUG
	NSLog(@"%s string:%@", __FUNCTION__, string);
#endif

	NSMutableString *result	= [[NSMutableString alloc] init];

	for(int i = 0; i < [string length]; i++) {
		NSString *character = [string substringWithRange:NSMakeRange(i, 1)];

		if([character isEqualToString:@"_"] == YES) {
			[result appendString:@"%"];
		} else {
			[result appendString:character];
		}
	}

#ifdef TKND_DEBUG
	NSLog(@"%s result:%@", __FUNCTION__, result);
#endif
	return result;
}


#pragma mark - screen size/center

//------------------------------------------------------------------------------
//	縦向き時の画面ザイズを取得する
//------------------------------------------------------------------------------
+ (CGSize)getScreenSizePortrait {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize result;

	result.width	= [[UIScreen mainScreen] bounds].size.width;
	result.height	= [[UIScreen mainScreen] bounds].size.height;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	横向き時の画面ザイズを取得する
//------------------------------------------------------------------------------
+ (CGSize)getScreenSizeLandscape {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	result;

	result.width	= [[UIScreen mainScreen] bounds].size.height;
	result.height	= [[UIScreen mainScreen] bounds].size.width;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	画面ザイズを取得する(過去互換用)
//	NOTE : 廃止予定
//------------------------------------------------------------------------------
+ (CGSize)getScreenSize {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize result = [self getScreenSizePortrait];

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	縦向き時のステータスバーを除いた画面ザイズを取得する
//------------------------------------------------------------------------------
+ (CGSize)getScreenSizeNoStatusBarPortrait {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize result;

	result.width	= [[UIScreen mainScreen] applicationFrame].size.width;
	result.height	= [[UIScreen mainScreen] applicationFrame].size.height;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	横向き時のステータスバーを除いた画面ザイズを取得する
//------------------------------------------------------------------------------
+ (CGSize)getScreenSizeNoStatusBarLandscape {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize result;

	result.width	= [[UIScreen mainScreen] applicationFrame].size.height;
	result.height	= [[UIScreen mainScreen] applicationFrame].size.width;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	ステータスバーを除いた画面ザイズを取得する(過去互換用)
//	NOTE : 廃止予定
//------------------------------------------------------------------------------
+ (CGSize)getScreenSizeNoStatusBar {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize result	= [self getScreenSizeNoStatusBarPortrait];

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.width, result.height);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	縦向き時の画面の中心点を取得する
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenterPortrait {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSizePortrait];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	横向き時の画面の中心点を取得する
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenterLandscape {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSizeLandscape];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	画面の中心点を取得する(過去互換用)
//	NOTE : 廃止予定
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenter {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSize];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	縦向き時のステータスバーを除いた画面の中心点を取得する
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenterNoStatusBarPortrait {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSizeNoStatusBarPortrait];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	横向き時のステータスバーを除いた画面の中心点を取得する
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenterNoStatusBarLandscape {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSizeNoStatusBarLandscape];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	ステータスバーを除いた画面の中心点を取得する(過去互換用)
//	NOTE : 廃止予定
//------------------------------------------------------------------------------
+ (CGPoint)getScreenCenterNoStatusBar {
#ifdef TKND_DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	CGSize	full	= [self getScreenSizeNoStatusBar];
	CGPoint	result;

	result.x	= full.width / 2;
	result.y	= full.height / 2;

#ifdef TKND_DEBUG
	NSLog(@"%s result.x:%f,  result.y:%f", __FUNCTION__, result.x, result.y);
#endif
	return result;
}


#pragma mark - Unique String
//------------------------------------------------------------------------------
//	twitterのAuthDataよりscreen_nameを取得する
//------------------------------------------------------------------------------
+ (NSString *)twitterUsernameFromAuthData {
//LOG();

	NSString *result = nil;

	if([[NSUserDefaults standardUserDefaults] objectForKey: @"authData"] != nil) {
		NSArray *array = [[[NSUserDefaults standardUserDefaults] objectForKey: @"authData"] componentsSeparatedByString:@"&"];
LOG(@"%@", array);
		for(int i = 0; i < [array count]; i++) {
			NSRange range =[(NSString *)[array objectAtIndex:i] rangeOfString:@"screen_name" options:NSCaseInsensitiveSearch];

			if(range.location != NSNotFound) {
				NSArray *array2 = [(NSString *)[array objectAtIndex:i] componentsSeparatedByString:@"="];
				result = [array2 objectAtIndex:1];
			}
		}
	}

#ifdef TKND_DEBUG
	NSLog(@"%@", result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	OSのバージョンを取得
//------------------------------------------------------------------------------
+ (NSString *)iOSVersion {
	NSString *result = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

#ifdef TKND_DEBUG
	NSLog(@"%s, %@", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	アプリバージョンを取得する
//------------------------------------------------------------------------------
+ (NSString *)appVersion {
	NSString *result = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

#ifdef TKND_DEBUG
	NSLog(@"%s %@", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	キャリア名を取得
//------------------------------------------------------------------------------
+ (NSString *)carrierName {
	NSString *result;

	CTTelephonyNetworkInfo	*netinfo	= [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier				*carrier	= [netinfo subscriberCellularProvider];

	if([carrier.carrierName length] > 0) {
		if([carrier.carrierName isEqualToString:@"ソフトバンクモバイル"] == YES) {
			result = @"SoftBank";
		} else
		if([carrier.carrierName isEqualToString:@"KDDI"] == YES) {
			result = @"KDDI";
		} else {
			result = @"none";
		}
	} else {
		result = @"none";
	}

#ifdef TKND_DEBUG
	NSLog(@"%s %@", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	ハードウェア機種名を取得
//------------------------------------------------------------------------------
+ (NSString *)hwMachine {
	// バッファサイズ取得
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);

	// ハードウェア機種名取得
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);

	// 文字列を変換
	NSString *result = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];

	free(machine);

#ifdef TKND_DEBUG
	NSLog(@"%s %@", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	デバイス名を取得
//------------------------------------------------------------------------------
+ (NSString *)deviceName {
	NSString		*machine		= [self hwMachine];
	NSString		*path			= [[NSBundle mainBundle] pathForResource:@"CarrierAndDevice" ofType:@"plist"];
	NSDictionary	*device_dic		= [NSDictionary dictionaryWithContentsOfFile:path];
	NSString		*result			= [[device_dic objectForKey:@"device"] objectForKey:machine];

	if(result == nil) {
		result = machine;
	}

#ifdef TKND_DEBUG
	NSLog(@"%s %@", __FUNCTION__, result);
#endif
	return result;
}

//------------------------------------------------------------------------------
//	ランダムなIDを作成 14文字のタイムスタンプ +　ランダムな文字列
//------------------------------------------------------------------------------
+ (NSString*)uniqueID {
	
	// タイムスタンプ作成 14文字
	NSDate *date = [NSDate date];
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyyMMddHHmmss"]; // 14文字
	NSString *timeString = [fmt stringFromDate:date];
	
	// 残り18文字追加
	static NSString *charas, *charas_Num;
    charas      = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	charas_Num  = @"0123456789";
	
	NSUInteger length, length_Num;
	length     = [charas length];
	length_Num = [charas_Num length];
	
	//LOG(@"----- 文字列の長さ:%d",length);
	NSMutableString *random_Charas, *random_Num, *randomString;
	random_Charas  = [NSMutableString stringWithCapacity:7]; // 任意の文字数
	random_Num     = [NSMutableString stringWithCapacity:11];
	randomString   = [NSMutableString stringWithCapacity:18];

	srand((unsigned)time(nil)); // ランダム初期化
	for (int i = 0; i < 11; i++) {
		if(i < 7){
			[random_Charas appendString:[charas substringWithRange:NSMakeRange(rand()%length, 1)]];
		}
		[random_Num appendString:[charas_Num substringWithRange:NSMakeRange(rand()%length_Num, 1)]];
	}
	//LOG(@"----- Random :%@, %@",random_Charas, random_Num);

	// 文字列を合わせる
	NSMutableString *shuffleString;
	shuffleString = [NSMutableString stringWithCapacity:18];
	[randomString appendString:random_Charas];
	[randomString appendString:random_Num];
	
	for (int i = 0; i < 18; i++) {
		[shuffleString appendString:[randomString substringWithRange:NSMakeRange(rand()%18, 1)]];
	}
	
	//LOG(@"***** created unique ID - %@",shuffleString);
	
	NSString *result = [NSString stringWithFormat:@"%@%@",timeString, shuffleString];

  LOG(@"***** length:%lu",(unsigned long)[result length]);
	
	return result;
}

@end
