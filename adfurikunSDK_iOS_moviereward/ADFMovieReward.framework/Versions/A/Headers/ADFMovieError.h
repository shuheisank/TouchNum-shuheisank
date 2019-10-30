//
//  ADFMovieError.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>

/**
 アドフリくん動画リワードSDK エラーコード

 - ADFMovieError_NoStock              : 在庫切れ
 - ADFMovieError_NetworkDisconnect    : ネットワーク未接続
 - ADFMovieError_InvalidAppId         : 不正な広告枠ID
 - ADFMovieError_ApiRequestFailure    : APIリクエスト失敗
 - ADFMovieError_PlayerItemLoadFailure: 動画の読み込み失敗
 - ADFMovieError_PlayerItemPlayFailure: 動画の最後まで再生失敗
 - ADFMovieError_Other                : その他のエラー
 */
typedef NS_ENUM(NSUInteger, ADFMovieErrorCode) {
    ADFMovieError_NoStock,
    ADFMovieError_NetworkDisconnect,
    ADFMovieError_InvalidAppId,
    ADFMovieError_ApiRequestFailure,
    ADFMovieError_UnsupportedOSVersion,
    ADFMovieError_PlayerItemLoadFailure,
    ADFMovieError_PlayerItemPlayFailure,
    ADFMovieError_Other,
};

/**
 エラーの情報を格納したオブジェクト
 */
@interface ADFMovieError : NSObject

/**
 エラーコード
 */
@property (nonatomic, readonly) ADFMovieErrorCode errorCode;
/**
 エラーが発生した広告枠ID
 */
@property (nonatomic, readonly, copy) NSString *appID;
/**
 エラーメッセージ
 */
@property (nonatomic, copy) NSString *errorMessage;

- (instancetype)initWithErrorCode:(ADFMovieErrorCode)errorCode appID:(NSString *)appID;

@end
