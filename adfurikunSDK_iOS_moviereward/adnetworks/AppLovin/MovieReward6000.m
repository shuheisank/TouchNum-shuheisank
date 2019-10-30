//
//  MovieReward6000.m(AppLovin)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "MovieReward6000.h"


@interface MovieReward6000()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong)NSString* appLovinSdkKey;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic, strong)NSString* zoneIdentifier;
@property (nonatomic, strong)ALIncentivizedInterstitialAd *incentivizedInterstitial;
@end


@implementation MovieReward6000

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return ALSdk.version;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    self.appLovinSdkKey = [data objectForKey:@"sdk_key"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if ( ![infoDict objectForKey:@"AppLovinSdkKey"] ) {
        [infoDict setValue:self.appLovinSdkKey  forKey:@"AppLovinSdkKey"];
    }
    //申請されたパッケージ名を受け取り
    self.submittedPackageName = [data objectForKey:@"package_name"];
    self.zoneIdentifier = [data objectForKey:@"zone_id"];
}

-(void)initAdnetworkIfNeeded {
    // Delegateを設定
    [MovieConfigure6000 configure];
    if (!self.incentivizedInterstitial) {
        if (self.zoneIdentifier && ![self.zoneIdentifier isEqual: [NSNull null]] && [self.zoneIdentifier length] != 0) {
            self.incentivizedInterstitial = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier:self.zoneIdentifier sdk:[ALSdk sharedWithKey:self.appLovinSdkKey]];
        } else {
            self.incentivizedInterstitial = [[ALIncentivizedInterstitialAd alloc] initWithSdk:[ALSdk sharedWithKey:self.appLovinSdkKey]];
        }
        self.incentivizedInterstitial.adDisplayDelegate = self;
        self.incentivizedInterstitial.adVideoPlaybackDelegate = self;
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    //NSLog(@"startAd");
    [self.incentivizedInterstitial preloadAndNotify: self];
}

-(BOOL)isPrepared{
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(self.submittedPackageName != nil
       && ![
            [self.submittedPackageName lowercaseString]
            isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]
            ])
    {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF][Applovin]アプリのバンドルIDが、申請されたものと異なります。");
    }
    return self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay;
}

-(void)showAd
{
    if (self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay) {
        [self.incentivizedInterstitial show];
    } else{
        NSLog(@"could not load ad");
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"ALSdk");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: ALSdk");
        return NO;
    }
    return YES;
}

/**
 *  広告の読み込みを中止
 */
-(void)cancel
{
    [[ALIncentivizedInterstitialAd shared] dismiss];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

// ------------------------------ -----------------
// ここからはApplovinのDelegateを受け取る箇所

/**
 *  広告の読み込み準備が終わった
 */
-(void) adService: (ALAdService *) adService didLoadAd: (ALAd *) ad
{
    NSLog(@"didLoadAd");
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        } else {
            NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

/**
 *  広告の読み込みに失敗
 */
-(void) adService: (ALAdService *) adService didFailToLoadAdWithError: (int) code
{
    NSLog(@"didFailToLoadAdWithError");
    [self setErrorWithMessage:nil code:code];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    }
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad: (ALAd *) ad wasDisplayedIn: (UIView *) view
{
    NSLog(@"wasDisplayedIn");
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad: (ALAd *) ad wasHiddenIn: (UIView *) view
{
    NSLog(@"wasHiddenIn");
    //[ALIncentivizedInterstitialAd preloadAndNotify:nil];
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad: (ALAd *) ad wasClickedIn: (UIView *) view
{
    NSLog(@"wasClickedIn");
}

/**
 *  広告（ビデオ)の表示を開始されたか
 */
-(void) videoPlaybackBeganInAd: (ALAd*) ad
{
    NSLog(@"videoPlaybackBeganInAd");
    // 広告の読み
    
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

/**
 *  広告の終了・停止時に呼ばれる
 *  パーセント、読み込み終わりの設定を表示
 */
-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent: (NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched
{
    NSLog(@"videoPlaybackBeganInAd");
    if ( wasFullyWatched ) {
        // 全てみた場合のみ。
        if ( self.delegate ) {
            if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                [self.delegate AdsDidCompleteShow:self];
            } else {
                NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }else{
        if ( self.delegate ) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self.delegate AdsPlayFailed:self];
            } else {
                NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

@end

@implementation MovieConfigure6000
+ (void)configure {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [ALSdk initializeSdk];
    });
}
@end

@implementation MovieReward6011

@end

@implementation MovieReward6012

@end

@implementation MovieReward6013

@end

@implementation MovieReward6014

@end

@implementation MovieReward6015

@end
