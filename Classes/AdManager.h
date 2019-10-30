//
//  AdManager.h
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/21.
//

#import <Foundation/Foundation.h>
#import <adfurikunsdk/AdfurikunView.h>  //バナー

//動画ネイティブ
#import <ADFMovieReward/ADFmyMovieNative.h>
#import "MovieNative6000.h" //AppLovin
#import "MovieNative6009.h" //nend
//動画インタースティシャル
#import <ADFMovieReward/ADFmyMovieInterstitial.h>
#import "MovieInterstitial6000.h" //AppLovin
#import "MovieInterstitial6001.h" //UnityAds
#import "MovieInterstitial6009.h" //nend
//動画リワード
#import <ADFMovieReward/ADFmyMovieReward.h>
#import "MovieReward6000.h" //AppLovin
#import "MovieReward6000.h" //UnityAds
#import "MovieReward6000.h" //nend

#import "TKND.h"


#define ADFR_BANNER_ID  @"50caa9eb4a09db487d00000f"
#define ADFR_MOVIE_NATIVE_ID  @"5d5bd51742f0844b0c000015"
#define ADFR_MOVIE_INTERSTITIAL_ID  @"5d5bd55b42f084e80b00000f"
#define ADFR_MOVIE_REWARD_ID  @"5d5c97c043f084e90f00000c"

#define INTERSTITIAL_FREQUENCY  4

#define IsIPad  ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

NS_ASSUME_NONNULL_BEGIN

@interface AdManager : NSObject <ADFmyMovieNativeDelegate, ADFmyMovieRewardDelegate>{
  AdfurikunView *adfurikunView;
  BOOL movieNativeIsShown;
  int interstitialCount;
  NSDate *showRewardedAdDate;
}
@property(nonatomic)UIView *view;
@property(nonatomic,nullable)ADFMovieNativeAdInfo *movieNativeAdInfo;
@property(nonatomic,nullable)ADFmyMovieInterstitial *movieInterstitial;
@property(nonatomic,nullable)ADFmyMovieReward *movieReward;

+(AdManager*)sharedManager;

-(void)showBanner;
-(void)hideBanner;

-(void)initMovieNative;
-(void)showMovieNative;
-(void)hideMovieNative;
-(void)reloadMovieNative;

-(void)initMovieInterstitial;
-(void)showMovieInterstitial;

-(void)initMovieReward;
-(BOOL)movieRewardIsPrepared;
-(void)showMovieReward;

-(BOOL)shouldShowAd;

@end

NS_ASSUME_NONNULL_END
