//
//  MovieInterstitial6009.m(NendAd)
//
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6009()<NADInterstitialVideoDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic, strong) NSString *nendAdspotId;
@property (nonatomic) BOOL didInit;

@property (nonatomic) NADInterstitialVideo *interstitialVideo;

@end

@implementation MovieInterstitial6009

#pragma mark - ADFmyMovieRewardInterface
/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data {
    self.nendKey = [NSString stringWithFormat:@"%@", [data objectForKey:@"api_key"]];
    self.nendAdspotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"adspot_id"]];
}

/**< 広告が準備できているか？ */
-(BOOL)isPrepared {
    return self.interstitialVideo.isReady;
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit) {
        self.interstitialVideo = [[NADInterstitialVideo alloc] initWithSpotId:self.nendAdspotId apiKey:self.nendKey];
        self.interstitialVideo.mediationName = @"adfurikun";
        self.interstitialVideo.isOutputLog = YES;
        self.interstitialVideo.delegate = self;
        self.didInit = YES;
    }

    // 動画広告のターゲティング
    [self setTargeting];
}

/**< 広告の読み込み開始 */
-(void)startAd {
    if (self.interstitialVideo) {
        [self.interstitialVideo loadAd];
    }

}

/**< 広告の表示 */
-(void)showAd {
    if (self.isPrepared) {
        UIViewController *topMostViewController = [self topMostViewController];
        if (topMostViewController) {
            [self.interstitialVideo showAdFromViewController:topMostViewController];
        }
        if (topMostViewController == nil) {
            NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
            if (self.delegate) {
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
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    if (self.interstitialVideo.isReady) {
        [self.interstitialVideo showAdFromViewController:viewController];
    }
}

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }
    
    Class clazz = NSClassFromString(@"NADInterstitialVideo");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
}

/**< 広告の読み込みを中止する処理 */
-(void)cancel {
    
}

/** アドネットワーク接続(特定のアドネットワーク) */
-(void)connectSetting:(NSDictionary*)keyDict {
    
}

- (void)setTargeting {
    NADUserFeature *feature = [NADUserFeature new];
    // 年齢
    int age = [ADFMovieOptions getUserAge];
    if (age > 0) {
        feature.age = age;
        self.interstitialVideo.userFeature = feature;
    }
    // 性別
    ADFMovieOptions_Gender gender = [ADFMovieOptions getUserGender];
    if (ADFMovieOptions_Gender_Male == gender) {
        feature.gender = NADGenderMale;
        self.interstitialVideo.userFeature = feature;
    } else if (ADFMovieOptions_Gender_Female == gender) {
        feature.gender = NADGenderFemale;
        self.interstitialVideo.userFeature = feature;
    }
}

-(void)dealloc{
    [self.interstitialVideo releaseVideoAd];
    self.didInit = NO;
}

#pragma mark - NADInterstitialVideoDelegate
- (void)nadInterstitialVideoAdDidReceiveAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadInterstitialVideoAd:(NADInterstitialVideo *)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __FUNCTION__, error);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        } else {
            NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nadInterstitialVideoAdDidOpen:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadInterstitialVideoAdDidClose:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nadInterstitialVideoAdDidStartPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nadInterstitialVideoAdDidStopPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadInterstitialVideoAdDidCompletePlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nadInterstitialVideoAdDidClickAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadInterstitialVideoAdDidClickInformation:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    NSLog(@"%s", __FUNCTION__);
}

@end
