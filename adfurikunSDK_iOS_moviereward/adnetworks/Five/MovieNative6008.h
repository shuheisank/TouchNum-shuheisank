//
//  MovieNative6008.h
//  MovieRewardSampleDev
//
//  Created by Junhua Li on 2018/06/22.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <ADFMovieReward/ADFmyMovieNativeInterface.h>
#import <ADFMovieReward/ADFMovieNativeAdInfo.h>
#import <FiveAd/FiveAd.h>

@interface MovieNative6008 : ADFmyMovieNativeInterface

@end

@interface MovieNativeAdInfo6008 : ADFMovieNativeAdInfo
@property(nonatomic) FADAdViewW320H180 *ad;
@end
