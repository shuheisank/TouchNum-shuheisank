//
//  ADFmyMovieNativeInterface.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>
#import "ADFMovieError.h"

@protocol ADFMovieNativeDelegate;
@class ADFMovieNativeAdInfo;

@interface ADFmyMovieNativeInterface : NSObject<NSCopying>

@property (nonatomic, weak) NSObject<ADFMovieNativeDelegate> *delegate;
@property (nonatomic) ADFMovieNativeAdInfo *adInfo;
@property (atomic) BOOL isAdLoaded;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSNumber *hasGdprConsent;


- (BOOL)isClassReference;
- (void)setData:(NSDictionary *)data;
- (void)initAdnetworkIfNeeded;
- (BOOL)isPrepared;
- (void)startAd;
- (void)cancel;

- (void)onImpression;
- (void)onMovieStart;
- (void)onMovieFinish;
- (void)onClick;

/** Errorを設定する */
-(void)setErrorWithMessage:(NSString *)description code:(NSInteger)code;
/** 最後のエラーを返す */
-(NSError *)getLastError;
/** EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。 */
-(void)setHasUserConsent:(BOOL)hasUserConsent;

//課題：ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion;

@end


@class ADFMovieNativeAdInfo;
@protocol ADFMovieNativeDelegate

@required
- (void)onNativeMovieAdImpression:(ADFmyMovieNativeInterface *)adapter;

@optional
- (void)onNativeMovieAdLoadFinish:(ADFMovieNativeAdInfo *)info;
- (void)onNativeMovieAdLoadError:(ADFmyMovieNativeInterface *)adapter;

- (void)onNativeMovieAdPlaybackStart:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlaybackFinish:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdClick:(ADFmyMovieNativeInterface *)adapter;

@end
