//
//  ADFmyMovieNativeAdFlex.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2017/12/28.
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "ADFmyMovieReward.h"

@interface ADFmyMovieNativeAdFlex : NSObject

/**
 動画ネイティブ広告（FLEX）のサポート対象OSバージョンかどうかを返却します

 @return YES: サポート対象OSバージョン, No: サボート対象外
 */
+ (BOOL)isSupportedOSVersion;

/**
 動画ネイティブ広告（FLEX）を初期化します(viewControllerなしで)。initWithAppIDからRenameされました。

 @param appID 広告枠ID
 */
+ (void)initializeWithAppID:(NSString *)appID ;

/**
 動画ネイティブ広告（FLEX）を初期化します。initWithAppIDからRenameされました。

 @param appID 広告枠ID
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;

/**
 動画ネイティブ広告（FLEX）を初期化します。initWithAppIDからRenameされました。

 @param appID 広告枠ID
 @param viewController 広告を表示するViewController
 */
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController; __deprecated_msg("Please use 'initializeWithAppID:' instead");
/**
 動画ネイティブ広告（FLEX）を初期化します。initWithAppIDからRenameされました。

 @param appID 広告枠ID
 @param viewController 広告を表示するViewController
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController option:(NSDictionary*)option; __deprecated_msg("Please use 'initializeWithAppID:option:' instead");

/**
 動画ネイティブ広告（FLEX）のデリゲートの設定とインスタンスを返却します

 @param appID 広告枠ID
 @param delegate デリゲートオブジェクト
 @return 動画ネイティブ広告（FLEX）のインスタンス
 */
+ (ADFmyMovieNativeAdFlex *)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 *
 */
-(void)load;
/**
 動画ネイティブ広告（FLEX）の準備状況を返却します

 @return YES: 表示可能, NO: 準備中
 */
- (BOOL)isPrepared;

/**
 動画ネイティブ広告（FLEX）の表示を開始します
 */
- (void)play;
- (void)playWithCustomParam:(NSDictionary*)param;
- (void)playWithPresentingViewController:(UIViewController *)viewController;
- (void)playWithPresentingViewController:(UIViewController *)viewController customParam:(NSDictionary*)param;

/**
 動画ネイティブ広告（FLEX）の表示を終了します
 画面遷移など任意のタイミングで広告を終了したい場合に利用してください
 */
- (void)finish;

@end
