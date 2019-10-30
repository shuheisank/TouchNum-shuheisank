//
//  SmaadVideoAd.h
//  SmaadVideoAd
//
//  created by GMOTECH, inc 2016
//

#import <Foundation/Foundation.h>

typedef enum
{
    VIDEO_STATUS_PLAY, //video playing
    VIDEO_STATUS_PAUSE, //video pause
    VIDEO_STATUS_STOP //video play stop
    
} SMAAD_VIDEO_STATUS;

typedef enum {
    COMPLETE,
    CANCEL,
    ERROR
} VIDEO_VIEW_END_STATE;

typedef NS_ENUM(NSInteger, SmaadErrorCode) {
    /// 不明なエラー
    SmaadUnknownError = 0,
    SmaadInvalidInitParam,
    SmaadNoNetworkConnection,
    SmaadFailedToStartVideo,
    SmaadFailedToPlayVideo,
    SmaadNoVideoFile,
    SmaadInvalidApiParam,
    SmaadNotFoundAd
    
};

@protocol SmaadVideoDelegate <NSObject>

@optional
// 広告枠初期化成功
- (void) didSuccessInit;

// 広告枠初期化失敗
- (void) didErrorInit:(SmaadErrorCode)errorCode;

// 動画広告再生準備完了
- (void) didReadyVideo;

// 動画広告再生開始(リプレイ時は呼ばれない)
- (void) didStartPlayVideo;

// 動画広告再生完了(リプレイ時は呼ばれない)
- (void) didCompletePlayVideo:(nonnull NSString *) pay;

// 動画途中終了
- (void) didStopPlayVideo;

// エンドカード閉じるボタン押下
- (void) didCloseEndcard;

// 動画広告再生実行時エラー
- (void) didErrorPlayVideo:(SmaadErrorCode)errorCode;

@end


@interface SmaadVideoAd : NSObject

@property(nonnull,nonatomic, readonly) NSString *zoneId;
@property(nullable, nonatomic, assign) id<SmaadVideoDelegate> delegate;
@property(nullable,nonatomic, readonly) NSString *userId;


+(nonnull SmaadVideoAd *)sharedInstance:(nonnull NSString *)zoneId;


/**
 initialzie 初期化
 */
-(void)initWithZoneId:(BOOL)disableSkip delegate:(nullable id<SmaadVideoDelegate>)delegate userId:(nullable NSString *)userId;

/**
 check what can play video ad 動画広告再生可能かどうか。
 */
-(BOOL)canPlayVideo;

/**
 play video 動画広告再生
 */
-(void)playVideoAd;



/**
 @enable :  YES -> print debug log ,  NO -> don't print debug log
    default value is YES
  YES -> デバッグログ取得可能
 */
-(void)setDebugMode:(BOOL)enable;

@end
