//
//  MovieNative6000.h(AppLovin)
//
//  (c) 2017 ADFULLY Inc.
//

#import <ADFMovieReward/ADFmyMovieNativeInterface.h>

#import <AppLovinSDK/AppLovinSDK.h>
#import <ADFMovieReward/ADFMovieNativeAdInfo.h>

@interface MovieNative6000 : ADFmyMovieNativeInterface

@end

@interface MovieNativeAdInfo6000 : ADFMovieNativeAdInfo<ALPostbackDelegate>

@property (nonatomic) ALNativeAd *ad;
@property (nonatomic, strong)NSString* appLovinSdkKey;

@end
