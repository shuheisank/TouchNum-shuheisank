//
//  MovieNative6000.m(AppLovin)
//
//  (c) 2017 ADFULLY Inc.
//

#import "MovieNative6000.h"
#import "MovieReward6000.h"

typedef NS_OPTIONS(NSUInteger, ADFALAdLoadStatus) {
    ADFALAdLoadStatus_None           = 0,
    ADFALAdLoadStatus_ImagePrecached = 1 << 0,
    ADFALAdLoadStatus_VideoPrecached = 1 << 1,
};

@interface MovieNative6000()<ALNativeAdLoadDelegate, ALNativeAdPrecacheDelegate>
@property (nonatomic, strong)NSString* appLovinSdkKey;
@property (atomic) BOOL requireMovie;
@property (atomic) ADFALAdLoadStatus loadStatus;
@end

@implementation MovieNative6000

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return ALSdk.version;
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"ALSdk");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: ALSdk");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    self.appLovinSdkKey = [data objectForKey:@"sdk_key"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if (![infoDict objectForKey:@"AppLovinSdkKey"] ) {
        [infoDict setValue:self.appLovinSdkKey forKey:@"AppLovinSdkKey"];
    }
    NSString *submittedPackageName = [data objectForKey:@"package_name"];
    self.requireMovie = false;

    //バンドルIDが申請済のパッケージ名と異なると、正常に広告が返却されない可能性があります
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if(submittedPackageName != nil &&
       ![[submittedPackageName lowercaseString] isEqualToString:[bundleId lowercaseString]]) {
        NSLog(@"[ADF][Applovin]アプリのバンドルIDが、申請されたものと異なります。");
    }
}

-(void)initAdnetworkIfNeeded {
    [MovieConfigure6000 configure];
}

- (void)startAd {
    self.loadStatus = ADFALAdLoadStatus_None;
    ALSdk *sdk = [ALSdk sharedWithKey:self.appLovinSdkKey];
    [sdk.nativeAdService loadNativeAdGroupOfCount:1 andNotify:self];
}

- (void)cancel {
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

- (BOOL)isPrecacheComplete:(ADFALAdLoadStatus)status {
    if ((status & ADFALAdLoadStatus_ImagePrecached) == ADFALAdLoadStatus_ImagePrecached &&
        (status & ADFALAdLoadStatus_VideoPrecached) == ADFALAdLoadStatus_VideoPrecached) {
        return YES;
    }
    return NO;
}

- (void)didPrecacheComplete:(ALNativeAd *)ad {
    if (self.requireMovie && ad.videoURL == nil) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
                [self.delegate onNativeMovieAdLoadError:self];
                return;
            } else {
                NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
 　　　　       MovieNativeAdInfo6000 *info = [[MovieNativeAdInfo6000 alloc] initWithVideoUrl:ad.videoURL
        　　　　                                                                        title:ad.title
               　　　　                                                           description:ad.descriptionText];
　　　　        info.appLovinSdkKey = self.appLovinSdkKey;
　　　　        info.adapter = self;
　　　　        info.ad = ad;
　　　　        [info setupMediaView:ad.imageURL movieUrl:ad.videoURL];
　　　　        self.adInfo = info;
　  　　　      [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"%s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

#pragma mark - ALNativeAdLoadDelegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray *)ads {
    [service precacheResourcesForNativeAd:ads.firstObject andNotify:self];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code {
    [self setErrorWithMessage:nil code:code];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

#pragma mark - ALNativeAdPrecacheDelegate

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheImagesForAd:(ALNativeAd *)ad {
    self.loadStatus |= ADFALAdLoadStatus_ImagePrecached;
    if ([self isPrecacheComplete:self.loadStatus]) {
        self.isAdLoaded = YES;
        [self didPrecacheComplete:ad];
    }
}

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheVideoForAd:(ALNativeAd *)ad {
    self.loadStatus |= ADFALAdLoadStatus_VideoPrecached;
    if ([self isPrecacheComplete:self.loadStatus]) {
        self.isAdLoaded = YES;
        [self didPrecacheComplete:ad];
    }

}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheImagesForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode {
    [self setErrorWithMessage:nil code:errorCode];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheVideoForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode {
    [self setErrorWithMessage:nil code:errorCode];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

@end


@implementation MovieNativeAdInfo6000

- (void)trackImpression {
    if (!self.hasTrackedImpression) {
        [[ALSdk sharedWithKey:self.appLovinSdkKey].postbackService dispatchPostbackAsync:self.ad.impressionTrackingURL andNotify:self];
    }
    [super trackImpression];
}

- (void)trackMovieStart {
    if (!self.hasTrackedMovieStart) {
        [[ALSdk sharedWithKey:self.appLovinSdkKey].postbackService dispatchPostbackAsync:self.ad.videoStartTrackingURL andNotify:self];
    }
    [super trackMovieStart];
}

- (void)trackMovieFinish {
    if (!self.hasTrackedMovieFinish) {
        NSURL *url = [self.ad videoEndTrackingURL:100 firstPlay:YES];
        [[ALSdk sharedWithKey:self.appLovinSdkKey].postbackService dispatchPostbackAsync:url andNotify:self];
    }
    [super trackMovieFinish];
}

- (void)launchClickTarget {
    [super launchClickTarget];
    [self.ad launchClickTarget];
}

#pragma mark - ALPostbackDelegate

- (void)postbackService:(ALPostbackService *)postbackService didExecutePostback:(NSURL *)postbackURL {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(NSURL *)postbackURL errorCode:(NSInteger)errorCode {
    NSLog(@"Failed to track, errorCode=%li", (long)errorCode);
}

@end
