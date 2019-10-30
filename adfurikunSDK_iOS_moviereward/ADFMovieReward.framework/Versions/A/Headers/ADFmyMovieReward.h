//
//  ADFmyMovieReward.h
//  ADFMovieReword
//
//  (3.1.0)
//  Created by tsukui on 2016/05/28.
//  (c) 2015 ADFULLY Inc.
//  (ご利用になられる前に、必ずマニュアルにて実装方法をご参照ください。
// マニュアルに記述されている実装のみ利用可能です)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADFmyMovieRewardInterface.h"

@protocol ADFmyMovieRewardDelegate;

@interface ADFmyMovieReward : NSObject<ADFMovieRewardDelegate>

/** 常に存在するViewController */
@property (nonatomic, weak) UIViewController *displayViewController;
/** デリゲート */
@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

/**
 サポートされているOSのバージョンか？
 @return BOOL サポートされているOSのバージョンか否か
 */
+ (BOOL)isSupportedOSVersion;
/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 */
+ (void)initializeWithAppID:(NSString *)appID;
/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;

/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 @param viewController 常に存在するViewController
 */
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController; __deprecated_msg("Please use 'initializeWithAppID:' instead");
/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 @param viewController 常に存在するViewController
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController option:(NSDictionary*)option; __deprecated_msg("Please use 'initializeWithAppID:option:' instead");

/**
 動画リワードのインスタンスを取得

 @param appID アドフリくんの広告枠ID
 @param delegate デリゲート
 @return 動画リワードのインスタンス
 */
+ (ADFmyMovieReward *)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;

/**
 インスタンスの処理
 */
+ (void)disposeAll;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 *
 */
-(void)load;

/**
 *  動画が準備完了しているか？
 *
 *  @return BOOL 動画が準備完了しているか否か
 */
-(BOOL)isPrepared;

/**
 *  動画を再生する
 */
-(void)play;
-(void)playWithCustomParam:(NSDictionary*)param;
-(void)playWithPresentingViewController:(UIViewController *)viewController;
-(void)playWithPresentingViewController:(UIViewController *)viewController customParam:(NSDictionary*)param;


-(void)dispose;

@end

#define ADF_FETCH_ERROR_CODE_OUTOFSTOCK 203
#define ADF_FETCH_ERROR_CODE_NOADNETWORK 400
#define ADF_FETCH_ERROR_CODE_ALREADY_LOADING 999

@protocol ADFmyMovieRewardDelegate<NSObject>
@optional
/**< 広告の表示準備が終わった時のイベント */
- (void)AdsFetchCompleted:(BOOL)isTestMode_inApp __deprecated_msg("Please use 'AdsFetchCompleted:isTestMode:' instead");
- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp;

/**< 広告の表示準備が失敗した時のイベント */
- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error;

/**< 広告の表示が開始した時のイベント */
- (void)AdsDidShow:(NSString *)adnetworkKey __deprecated_msg("Please use 'AdsDidShow:adNetworkKey:' instead");
- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey;

/**< 広告の表示が最後まで終わった時のイベント */
- (void)AdsDidCompleteShow __deprecated_msg("Please use 'AdsDidCompleteShow:' instead");
- (void)AdsDidCompleteShow:(NSString *)appID;

/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed __deprecated_msg("Please use 'AdsPlayFailed:' instead");
- (void)AdsPlayFailed:(NSString *)appID;

/**< 広告を閉じた時のイベント */
- (void)AdsDidHide __deprecated_msg("Please use 'AdsDidHide:' instead");
- (void)AdsDidHide:(NSString *)appID;

@end
