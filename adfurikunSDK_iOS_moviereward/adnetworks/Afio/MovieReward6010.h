//
//  MovieReward6010.h(Afio)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
#import <ADFMovieReward/ADFmyMovieDelegateBase.h>
#import <AMoAd/AMoAd.h>
#import <AMoAd/AMoAdInterstitial.h>
#import <AMoAd/AMoAdInterstitialVideo.h>

@interface MovieReward6010 : ADFmyMovieRewardInterface<AMoAdInterstitialVideoDelegate>

@property (nonatomic) AMoAdInterstitialVideo *amoadInterstitialVideo;

-(void)setCancellable;

@end
