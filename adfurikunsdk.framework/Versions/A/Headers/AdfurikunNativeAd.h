//
//  AdfurikunNativeAd.h
//
//  Copyright (c) Terajima Joho Kikaku Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "AdfurikunNativeAdInfo.h"

@protocol AdfurikunNativeAdDelegate <NSObject>
/** デリゲートの定義 */
@required
-(void)apiDidFinishLoading:(AdfurikunNativeAdInfo *)nativeAdInfo adnetworkKey:(NSString *)adnetworkKey;
-(void)apiDidFailWithError:(int)err adnetworkKey:(NSString *)adnetworkKey;
@end

@interface AdfurikunNativeAd : NSObject

@property (weak, nonatomic) id<AdfurikunNativeAdDelegate> delegate;
//@property
/**
 * 広告表示を開始する。
 */
-(id)init:(NSString *)withAppID;
/** ネイティブ広告の呼び出し */
-(void)getNativeAd;
/** APIの返却が正常取得した場合に呼ばれる */
-(void)apiDidFinishLoading:(AdfurikunNativeAdInfo *)nativeAdInfo adnetworkKey:(NSString *)adnetworkKey;
/** APIの返却が正常取得できなかった場合に呼ばれる */
-(void)apiDidFailWithError:(int)err adnetworkKey:(NSString *)adnetworkKey;

-(NSString*)getAppId;
@end
