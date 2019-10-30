//
//  MovieNative6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/10.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
#import "MovieNative6016.h"

@interface MovieNative6016()<FBNativeAdDelegate, FBMediaViewDelegate>
@property (nonatomic, strong) NSString *placement_id;
@property (nonatomic, strong) FBNativeAd *nativeAd;
@end

@implementation MovieNative6016

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FBNativeAd");
    if (clazz) {
    } else {
        NSLog(@"MovieNative6016: Not found Class: FBNativeAd");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    self.placement_id = [NSString stringWithFormat:@"%@", [data objectForKey:@"placement_id"]];
}

- (void)startAd {
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID: self.placement_id];
    nativeAd.delegate = self;
    [nativeAd loadAd];
}

- (BOOL)isPrepared {
    return self.nativeAd && [self.nativeAd isAdValid] && self.isAdLoaded;
}

-(void)findMediaViewRecursive:(UIView*)uiView {
    for (UIView *view in uiView.subviews) {
        NSString *className = NSStringFromClass(view.class);
        if ([className isEqualToString:@"FBMediaView"]) {
            FBMediaView *v = (FBMediaView *)view;
            v.delegate = self;
        }
    }
}

#pragma mark - FBNativeAdDelegate delegates
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    NSLog(@"MovieNative6016: NativeAd Loaded");
    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }
    self.nativeAd = nativeAd;
    MovieNativeAdInfo6016 *info = [[MovieNativeAdInfo6016 alloc] initWithVideoUrl:nil title:nativeAd.advertiserName description:nativeAd.bodyText];

    FBNativeAdViewAttributes *attributes = [[FBNativeAdViewAttributes alloc] init];
    attributes.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    attributes.buttonColor = [UIColor colorWithRed:66/255.0 green:108/255.0 blue:173/255.0 alpha:1];
    attributes.buttonTitleColor = [UIColor whiteColor];

    FBNativeAdView *adView = [FBNativeAdView nativeAdViewWithNativeAd: nativeAd
                                                             withType: FBNativeAdViewTypeGenericHeight300
                                                       withAttributes: attributes];

    for (UIView *view in adView.subviews) {
        [self findMediaViewRecursive: view];
    }

    [info setupMediaView: adView];

    //---creating fan components for user assembly]
    info.isCustomComponentSupported = YES;
    info.nativeAd = nativeAd;

    info.fbAdTitleLabel = [[UILabel alloc] init];
    info.fbAdTitleLabel.text = nativeAd.advertiserName;

    info.fbAdBodyLabel = [[UILabel alloc] init];
    [info.fbAdBodyLabel setText: nativeAd.bodyText];

    info.fbSocialContextLabel = [[UILabel alloc] init];
    [info.fbSocialContextLabel setText: nativeAd.socialContext];

    info.fbCallToActionButton = [[UIButton alloc] init];
    [info.fbCallToActionButton setTitle: nativeAd.callToAction forState: UIControlStateNormal];

    info.fbAdChoicesView = [[FBAdChoicesView alloc] init];
    info.fbAdChoicesView.nativeAd = nativeAd;

    info.fbMediaView = [[FBMediaView alloc] init];
    info.fbMediaView.delegate = self;

    info.fbAdIconView = [[FBAdIconView alloc] init];
    //-------------------------------------------------

    info.adapter = self;
    self.adInfo = info;
    self.isAdLoaded = true;
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish: self.adInfo];
        } else {
            NSLog(@"MovieNative6016: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    NSLog(@"%s", __func__);
    NSLog(@"MovieNative6016: NativeAdDidClick");
    if (self.adInfo.mediaView.mediaViewDelegate) {
        if ([self.adInfo.mediaView.mediaViewDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.mediaViewDelegate onADFMediaViewClick];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.mediaViewDelegate is not setting", __FUNCTION__);
    }
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd {
    NSLog(@"MovieNative6016: NativeAd will log impression");
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    NSLog(@"MovieNative6016: NativeAd load failed with error");
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError: self];
        } else {
            NSLog(@"MovieNative6016: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"MovieNative6016: delegate is not set");
    }
}

#pragma mark - FBMediaViewDelegate delegates

- (void)mediaViewDidLoad:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: Media View did load");
    NSLog(@"%s", __func__);

}

- (void)mediaViewVideoDidPlay:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView play");

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)mediaViewVideoDidPause:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView pause");
}

- (void)mediaViewVideoDidComplete:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView finished playing");

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

@end

@implementation MovieNativeAdInfo6016
- (void)playMediaView {
    NSLog(@"%s", __func__);
}

- (void)registerViewForInteraction:(UIView *)view viewController:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews {
    [self.nativeAd registerViewForInteraction:view
                                    mediaView:self.fbMediaView
                                     iconView:self.fbAdIconView
                               viewController:viewController
                               clickableViews:clickableViews];
}

- (NSDictionary *)getCustomNativeAdComponents {
    return @{
             @"adTitleLabel": self.fbAdTitleLabel,
             @"adMediaView": self.fbMediaView,
             @"adIconView": self.fbAdIconView,
             @"adChoicesView": self.fbAdChoicesView,
             @"adCallToActionButton": self.fbCallToActionButton,
             @"adSocialContextLabel": self.fbSocialContextLabel,
             @"adBodyLabel": self.fbAdBodyLabel };
}

@end


