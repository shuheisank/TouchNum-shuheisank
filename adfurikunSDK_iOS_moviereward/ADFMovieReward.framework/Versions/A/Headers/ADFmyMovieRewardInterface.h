//
//  ADFMovieRewardInterface.h
//
//
//  (c) 2015 ADFULLY Inc.
//
//

#import <Foundation/Foundation.h>

@class UIViewController;

@protocol ADFMovieRewardDelegate;

@interface ADFmyMovieRewardInterface : NSObject<NSCopying>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSObject<ADFMovieRewardDelegate> *delegate;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSNumber *hasGdprConsent;

/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data;
/**< Adnetwork SDKを初期化する （Optional） */
-(void)initAdnetworkIfNeeded;
/**< 広告が準備できているか？ */
-(BOOL)isPrepared;
/**< 広告の読み込み開始 */
-(void)startAd;
/**< 広告の表示 */
-(void)showAd;
-(void)showAdWithPresentingViewController:(UIViewController *)viewController;
/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference;
/**< 広告の読み込みを中止する処理 */
-(void)cancel;
/** アドネットワーク接続(特定のアドネットワーク) */
-(void)connectSetting:(NSDictionary*)keyDict;
/** Errorを設定する */
-(void)setErrorWithMessage:(NSString *)description code:(NSInteger)code;
/** 最後のエラーを返す */
-(NSError *)getLastError;
-(UIViewController *)topMostViewController;
/** EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。 */
-(void)setHasUserConsent:(BOOL)hasUserConsent;
@end

@protocol ADFmyMovieNativeAdFlexInterface
- (void)finishAd;
@end

@protocol ADFMovieRewardDelegate
@optional

/**< 広告の表示準備が終わったか？ */
- (void)AdsFetchCompleted:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示準備が失敗 */
- (void)AdsFetchError:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示が開始したか */
- (void)AdsDidShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告がバックグラウンドに回ったか */
- (void)AdsDidHide:(ADFmyMovieRewardInterface*)movieReward;
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(ADFmyMovieRewardInterface*)movieReward;

/** アドネットワーク接続後のイベント(特定のアドネットワーク用) */
- (void)AdsDidConnect:(ADFmyMovieRewardInterface*)movieReward;

//課題：ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion;

@end
