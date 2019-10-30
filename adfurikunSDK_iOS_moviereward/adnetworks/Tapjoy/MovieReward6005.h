//
//  MovieReward6005.h (Tapjoy)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
#import <ADFMovieReward/ADFmyMovieDelegateBase.h>

#import <Tapjoy/Tapjoy.h>
#import <Tapjoy/TJPlacement.h>

@interface MovieReward6005 : ADFmyMovieRewardInterface

@end

/**
 *  Tapjoy用のDelegateクラス
 */
@interface MovieDelegate6005 : ADFmyMovieDelegateBase<TJPlacementDelegate, TJPlacementVideoDelegate>
+ (instancetype)sharedInstance;

@end
