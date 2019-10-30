//
//  MovieReward6000.h(AppLovin)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
//#import "ADFmyMovieRewardInterface.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface MovieReward6000 : ADFmyMovieRewardInterface

@end

@interface MovieConfigure6000 : NSObject
+ (void)configure;
@end

// 同一広告枠に複数のAppLovin Zoneをサポートする
@interface MovieReward6011 : MovieReward6000

@end

@interface MovieReward6012 : MovieReward6000

@end

@interface MovieReward6013 : MovieReward6000

@end

@interface MovieReward6014 : MovieReward6000

@end

@interface MovieReward6015 : MovieReward6000

@end
