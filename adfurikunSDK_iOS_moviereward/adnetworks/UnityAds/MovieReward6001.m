//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"


@interface MovieReward6001()
@property (nonatomic, strong)NSString *gameId;
@property (nonatomic, strong)NSString *placement_id;
@property (nonatomic, assign)BOOL isCompleted;
@end

@implementation MovieReward6001

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return UnityAds.getVersion;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    
    BOOL testFlg = [[data objectForKey:@"test_flg"] boolValue];
    if (!testFlg) {
        [UnityAds setDebugMode:testFlg];
    }
    self.gameId = [NSString stringWithFormat:@"%@",[data objectForKey:@"game_id"]];
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if (data_placement_id && ![data_placement_id isEqual:[NSNull null]]) {
        self.placement_id = [NSString stringWithFormat:@"%@",[data objectForKey:@"placement_id"]];
    }
    _isCompleted = NO;
}

-(void)initAdnetworkIfNeeded {
    MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
    [delegate setMovieReward:self inZone:self.placement_id];
    [UnityAds setDelegate:[MovieDelegate6001 sharedInstance]];
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    [[MovieDelegate6001 sharedInstance] setDelegate:self.delegate inZone:self.placement_id];

    if (![UnityAds isInitialized]) {
        // 初期化は1回のみ。1回のみになっているか？？
        [UnityAds initialize:self.gameId delegate:[MovieDelegate6001 sharedInstance]];
    }
}

-(BOOL)isPrepared{
  if (self.placement_id) {
    return ([UnityAds isReady:self.placement_id] && self.delegate);
  } else {
    return ([UnityAds isReady] && self.delegate);
  }
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    if (self.isPrepared) {
        UIViewController *topMostViewController = [self topMostViewController];
        if (topMostViewController) {
            if (self.placement_id) {
                [UnityAds show:topMostViewController placementId:self.placement_id];
            } else {
                [UnityAds show:topMostViewController];
            }
        }
        if (topMostViewController == nil) {
            NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self.delegate AdsPlayFailed:self];
            }
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    if (self.isPrepared) {
        if (self.placement_id) {
            [UnityAds show:viewController placementId:self.placement_id];
        } else {
            [UnityAds show:viewController];
        }
    }
}


/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"MovieReward6001 isClassReference");
    Class clazz = NSClassFromString(@"UnityAds");
    if (clazz) {
        NSLog(@"found Class: UnityAds");
        return YES;
    }
    else {
        NSLog(@"Not found Class: UnityAds");
        return NO;
    }
}

/**
 *  広告の読み込みを中止
 */
-(void)cancel {
// 2.0で廃止  [UnityAds stopAll];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:hasUserConsent ? @YES : @NO];
    [gdprConsentMetaData commit];
}

-(void)dealloc {
    _gameId = nil;
}
@end

@implementation MovieDelegate6001
+ (instancetype)sharedInstance {
    static MovieDelegate6001 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

// ------------------------------ -----------------
// ここからはUnityAdsのDelegateを受け取る箇所

#pragma mark - UnityAdsDelegate
// 動画の再生開始
- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"《 UnityAds Callback 》unityAdsDidStart");
    id delegate = [self getDelegateWithZone:placementId];
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [delegate AdsDidShow:movieReward];
        }
    }
}

// 広告を閉じる
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    id delegate = [self getDelegateWithZone:placementId];
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    
    switch (state) {
        case kUnityAdsFinishStateCompleted:
            NSLog(@"%s kUnityAdsFinishStateCompleted %@", __func__, placementId);
            if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                [delegate AdsDidCompleteShow:movieReward];
            }
            break;
        case kUnityAdsFinishStateSkipped:
            NSLog(@"%s kUnityAdsFinishStateSkipped %@", __func__, placementId);
            break;
        default:
            NSLog(@"%s other %@", __func__, placementId);
            if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [delegate AdsPlayFailed:movieReward];
            }
            break;
    }

    if ([delegate respondsToSelector:@selector(AdsDidHide:)]) {
        [delegate AdsDidHide:movieReward];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(nonnull NSString *)message {
}


- (void)unityAdsReady:(nonnull NSString *)placementId {
    id delegate = [self getDelegateWithZone:placementId];
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    // 広告準備完了
    NSLog(@"%s %@", __func__, placementId);
    if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
        [delegate AdsFetchCompleted:movieReward];
    }
}


@end
