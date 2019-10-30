//
//  MovieNative6009.m
//  MovieRewardSampleDev
//
//  Created by Sungil Kim on 2018/07/12.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieNative6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieNative6009()<NADNativeVideoDelegate, NADNativeVideoViewDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic, strong) NSString *nendAdspotId;
@property (nonatomic) BOOL didInit;
@property (nonatomic) NADNativeVideoClickAction clickAction;

@property (nonatomic, strong) NADNativeVideoView *nativeVideoView;
@property (nonatomic, strong) NADNativeVideoLoader *videoAdLoader;

@end

@implementation MovieNative6009

- (BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }

    Class clazz = NSClassFromString(@"NADNativeVideoLoader");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    self.nendKey = [NSString stringWithFormat:@"%@", [data objectForKey:@"api_key"]];
    self.nendAdspotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"adspot_id"]];
    NSNumber *clickAction = [data objectForKey:@"click_action"];
    if (clickAction && ![clickAction isEqual:[NSNull null]]) {
        self.clickAction = clickAction.integerValue;
    } else {
        self.clickAction = NADNativeVideoClickActionFullScreen;
    }
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit) {
        self.videoAdLoader = [[NADNativeVideoLoader alloc] initWithSpotId:self.nendAdspotId apiKey:self.nendKey clickAction:self.clickAction];
        self.videoAdLoader.mediationName = @"adfurikun";
        // 動画広告のターゲティング
        [self setTargeting];

        self.didInit = YES;
    }
}

- (void)startAd {
    MovieNative6009 __weak *weakSelf = self;
    [self.videoAdLoader loadAdWithCompletionHandler:^(NADNativeVideo * _Nullable videoAd, NSError * _Nullable error) {
        if (weakSelf) {
            if (videoAd) {
                NSLog(@"nend NativeAd Load completed");
                MovieNativeAdInfo6009 *info = [[MovieNativeAdInfo6009 alloc] initWithVideoUrl:nil
                                                                                        title:videoAd.title
                                                                                  description:videoAd.explanation];
                info.adapter = weakSelf;

                videoAd.mutedOnFullScreen = true;
                videoAd.delegate = weakSelf;

                weakSelf.nativeVideoView = [[NADNativeVideoView alloc] initWithFrame:CGRectZero];
                weakSelf.nativeVideoView.delegate = weakSelf;
                weakSelf.nativeVideoView.videoAd = videoAd;
                [info setupMediaView:weakSelf.nativeVideoView];

                weakSelf.adInfo = info;
                weakSelf.isAdLoaded = true;

                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
                        [weakSelf.delegate onNativeMovieAdLoadFinish:weakSelf.adInfo];
                    } else {
                        NSLog(@"%s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
                    }
                } else {
                    NSLog(@"%s Delegate is not setting", __FUNCTION__);
                }


            } else {
                weakSelf.isAdLoaded = false;
                NSLog(@"nend NativeAd load error : %@", error.localizedDescription);
                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
                        [weakSelf.delegate onNativeMovieAdLoadError:weakSelf];
                    } else {
                        NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
                    }
                } else {
                    NSLog(@"%s Delegate is not setting", __FUNCTION__);
                }
            }
        }
    }];
}

- (void)cancel {
}

- (void)setTargeting {
    NADUserFeature *feature = [NADUserFeature new];
    // 年齢
    int age = [ADFMovieOptions getUserAge];
    if (age > 0) {
        feature.age = age;
        self.videoAdLoader.userFeature = feature;
    }
    // 性別
    ADFMovieOptions_Gender gender = [ADFMovieOptions getUserGender];
    if (ADFMovieOptions_Gender_Male == gender) {
        feature.gender = NADGenderMale;
        self.videoAdLoader.userFeature = feature;
    } else if (ADFMovieOptions_Gender_Female == gender) {
        feature.gender = NADGenderFemale;
        self.videoAdLoader.userFeature = feature;
    }
}

-(void)dealloc{
    self.didInit = NO;
    self.adInfo = nil;
    self.nativeVideoView = nil;
    self.videoAdLoader = nil;
}

#pragma mark - NADNativeVideoDelegate
- (void)nadNativeVideoDidImpression:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoDidClickAd:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.mediaViewDelegate) {
        if ([self.adInfo.mediaView.mediaViewDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.mediaViewDelegate onADFMediaViewClick];
        } else {
            NSLog(@"%s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.mediaViewDelegate is not setting", __FUNCTION__);
    }
}

- (void)nadNativeVideoDidClickInformation:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);
}

#pragma mark - NADNativeVideoViewDelegate
- (void)nadNativeVideoViewDidStartPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"%s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)nadNativeVideoViewDidStopPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidFailToPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFail)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFail];
        } else {
            NSLog(@"%s onADFMediaViewPlayFail selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)nadNativeVideoViewDidCompletePlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"%s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)nadNativeVideoViewDidOpenFullScreen:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidCloseFullScreen:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

@end

@implementation MovieNativeAdInfo6009

- (void)playMediaView {
    NSLog(@"%s", __func__);
}

@end

