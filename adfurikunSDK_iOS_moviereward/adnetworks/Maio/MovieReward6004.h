//
//  MovieReword6004.h
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
//#import "ADFmyMovieRewardInterface.h"
#import <Maio/Maio.h>


@interface MovieReward6004 : ADFmyMovieRewardInterface

@end


/**
 *  Maio用のDelegateクラス
 */
@interface MovieDelegate6004 : NSObject<MaioDelegate>

+ (instancetype)sharedInstance;
- (void)setMovieReward:(ADFmyMovieRewardInterface *)movieReward inZone:(NSString *)zoneId;
- (void)setDelegate:(id<ADFMovieRewardDelegate>)delegate inZone:(NSString *)zoneId;

@end
