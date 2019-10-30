//
//  MovieReward6009.m(NendAd)
//
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6009()<NADRewardedVideoDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic, strong) NSString *nendAdspotId;
@property (nonatomic) BOOL didInit;

@property (nonatomic) NADRewardedVideo *rewardedVideo;

@end

@implementation MovieReward6009

#pragma mark - ADFmyMovieRewardInterface
/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data {
    self.nendKey = [NSString stringWithFormat:@"%@", [data objectForKey:@"api_key"]];
    self.nendAdspotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"adspot_id"]];
}

/**< 広告が準備できているか？ */
-(BOOL)isPrepared {
    return self.rewardedVideo.isReady;
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit) {
        self.rewardedVideo = [[NADRewardedVideo alloc] initWithSpotId:self.nendAdspotId apiKey:self.nendKey];
        self.rewardedVideo.mediationName = @"adfurikun";
        self.rewardedVideo.isOutputLog = YES;
        self.rewardedVideo.delegate = self;
        self.didInit = YES;
    }

    // 動画広告のターゲティング
    [self setTargeting];
}

/**< 広告の読み込み開始 */
-(void)startAd {
    if (self.rewardedVideo) {
        [self.rewardedVideo loadAd];
    }
}

/**< 広告の表示 */
-(void)showAd {
    if (self.isPrepared) {
        UIViewController *topMostViewController = [self topMostViewController];
        if (topMostViewController) {
            [self.rewardedVideo showAdFromViewController:topMostViewController];
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
    if (self.rewardedVideo.isReady) {
        [self.rewardedVideo showAdFromViewController:viewController];
    }
}

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }
    
    Class clazz = NSClassFromString(@"NADRewardedVideo");
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
        self.rewardedVideo.userFeature = feature;
    }
    // 性別
    ADFMovieOptions_Gender gender = [ADFMovieOptions getUserGender];
    if (ADFMovieOptions_Gender_Male == gender) {
        feature.gender = NADGenderMale;
        self.rewardedVideo.userFeature = feature;
    } else if (ADFMovieOptions_Gender_Female == gender) {
        feature.gender = NADGenderFemale;
        self.rewardedVideo.userFeature = feature;
    }
}

-(void)dealloc{
    [self.rewardedVideo releaseVideoAd];
    self.didInit = NO;
}

#pragma mark - NADRewardedVideoDelegate
- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error {
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

- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd {
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

- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd {
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

- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
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

- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd {
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

- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    
}


@end
