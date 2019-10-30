//
//  AdManager.m
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/21.
//

#import "AdManager.h"

static AdManager *sharedManager;

@implementation AdManager
@synthesize view;
@synthesize movieNativeAdInfo;
@synthesize movieInterstitial;
@synthesize movieReward;

#pragma mark - Singleton

+(AdManager*)sharedManager{
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

+(id)allocWithZone:(struct _NSZone *)zone{
  
  __block id ret = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedManager = [super allocWithZone:zone];
    ret = sharedManager;
  });
  return ret;
}

#pragma mark - Banner

-(void)showBanner{
  if(![self shouldShowAd])return;

    LOG(@"***********");
  CGSize screenSize = [TKND getScreenSize];
  

  
  if(!adfurikunView){
    adfurikunView = [[AdfurikunView alloc] initWithFrame:
                     CGRectMake(
                                0.0f,
                                screenSize.height -  ADFRJS_VIEW_SIZE_320x50.height,
                                ADFRJS_VIEW_SIZE_320x50.width,
                                ADFRJS_VIEW_SIZE_320x50.height
                                )];
    adfurikunView.appID = ADFR_BANNER_ID;

  }
  
  if(IsIPad){
    LOG(@"--------");
    adfurikunView.frame = CGRectMake(
                                    0.0f,
                                    (screenSize.height -  ADFRJS_VIEW_SIZE_320x50.height)/2,
                                    ADFRJS_VIEW_SIZE_320x50.width/2,
                                    ADFRJS_VIEW_SIZE_320x50.height/2
                                     );
  }
  
  [self.view addSubview:adfurikunView];
  [adfurikunView startShowAd];
  
  [self hideMovieNative];
}
-(void)hideBanner{
  if (!adfurikunView) [adfurikunView removeFromSuperview];
  
}

#pragma mark - MovieNative
-(void)initMovieNative{
  LOG();
  if ([ADFmyMovieNative isSupportedOSVersion] && !IsIPad) {
    [ADFmyMovieNative initializeWithAppID:ADFR_MOVIE_NATIVE_ID];
    [[ADFmyMovieNative getInstance:ADFR_MOVIE_NATIVE_ID] loadAndNotifyTo:self];
    movieNativeIsShown = NO;
  }
}
-(void)showMovieNative{
  if(![self shouldShowAd] || IsIPad)return;

  LOG();
  if(self.movieNativeAdInfo!=nil){
    [self.view addSubview:self.movieNativeAdInfo.mediaView];
    [self.movieNativeAdInfo playMediaView];
    [self hideBanner];
    movieNativeIsShown = true;
  }else{
    [self reloadMovieNative];
    [self showBanner];
  }
  
}
-(void)hideMovieNative{
  LOG();
  if (self.movieNativeAdInfo) {
    if(![self shouldShowAd]){
      LOG(@"[self.movieNativeAdInfo.mediaView removeFromSuperview];");
      [self.movieNativeAdInfo.mediaView removeFromSuperview];
      return;
    }else{
      [self reloadMovieNative];
    }
  }
}
-(void)reloadMovieNative{
  LOG(@"%d: %@",movieNativeIsShown,self.movieNativeAdInfo);
  
  if (movieNativeIsShown) {
    [self.movieNativeAdInfo.mediaView removeFromSuperview];
    self.movieNativeAdInfo.mediaView = nil;
    self.movieNativeAdInfo = nil;
    [[ADFmyMovieNative getInstance:ADFR_MOVIE_NATIVE_ID] loadAndNotifyTo:self];
    [self showBanner];
  }else{
    if(self.movieNativeAdInfo){
      LOG(@"*-");
    }else{
      LOG(@"*+");
      [[ADFmyMovieNative getInstance:ADFR_MOVIE_NATIVE_ID] loadAndNotifyTo:self];
      [self showBanner];
    }
  }

}

#pragma mark - ADFmyMovieNativeDelegate

- (void)onNativeMovieAdLoadFinish:(ADFMovieNativeAdInfo *)info appID:(NSString *)appID{
  LOG(@"%@",info);
  CGSize screenSize = [TKND getScreenSize];
  
  float w_ = ADFRJS_VIEW_SIZE_320x50.width;
  float h_ = w_*0.5625f;
  info.mediaView.frame = CGRectMake(0.0f, screenSize.height -  h_, w_, h_);
  self.movieNativeAdInfo = info;
  movieNativeIsShown = false;
}
- (void)onNativeMovieAdLoadError:(ADFMovieError *)error appID:(NSString *)appID{
  LOG(@"%@",error.errorMessage);
}

#pragma mark - MovieInterstitial

-(void)initMovieInterstitial{
  LOG();
  if ([ADFmyMovieInterstitial isSupportedOSVersion] ) {
    [ADFmyMovieInterstitial initializeWithAppID:ADFR_MOVIE_INTERSTITIAL_ID];
    self.movieInterstitial = [ADFmyMovieInterstitial getInstance:ADFR_MOVIE_INTERSTITIAL_ID delegate:self];
    [self.movieInterstitial load];
    interstitialCount = INTERSTITIAL_FREQUENCY;
  }
}
-(void)showMovieInterstitial{
  interstitialCount--;
  LOG(@"interstitialCount:%d",interstitialCount);

  if(![self shouldShowAd])return;

  if(interstitialCount>0) return;
  if(self.movieInterstitial!=nil){
    if([self.movieInterstitial isPrepared]){
      [self.movieInterstitial play];
    }
  }
}

#pragma mark - MovieReward
-(void)initMovieReward{
  LOG();
  if ([ADFmyMovieReward isSupportedOSVersion]) {
    [ADFmyMovieReward initializeWithAppID:ADFR_MOVIE_REWARD_ID];
    self.movieReward = [ADFmyMovieReward getInstance:ADFR_MOVIE_REWARD_ID delegate:self];
    [self.movieReward load];
    showRewardedAdDate = [NSDate dateWithTimeIntervalSinceNow:-30*60];
  }
}
-(BOOL)movieRewardIsPrepared{
  LOG();
  return [self.movieReward isPrepared];
}

-(void)showMovieReward{
  LOG();
  if(![self shouldShowAd])return;
  
  if ([self.movieReward isPrepared]) {
    [self.movieReward play];
  }
}

#pragma mark - ADFmyMovieRewardDelegate

- (void)AdsFetchCompleted:(BOOL)isTestMode_inApp {
  LOG();
}

- (void)AdsDidShow:(NSString*)adnetworkKey {
  LOG();
  interstitialCount = INTERSTITIAL_FREQUENCY;
}

- (void)AdsDidCompleteShow {
  LOG();
}

- (void)AdsDidHide:(NSString *)appID{
  LOG(@"");
  if([appID isEqualToString:ADFR_MOVIE_REWARD_ID]){
    LOG(@"リワード広告最後まで見た");
    showRewardedAdDate = [NSDate date];
    [self hideBanner];
    [self hideMovieNative];
  }
}

- (void)AdsPlayFailed {
  LOG();
}

#pragma mark -

-(BOOL)shouldShowAd{
  LOG(@"%@",showRewardedAdDate);
  
  BOOL retval = [[NSDate date] timeIntervalSinceDate:showRewardedAdDate]>15*60;
  return retval;
}

@end

