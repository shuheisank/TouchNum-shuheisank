//
//  MovieReward6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6006.h"

@interface MovieReward6006()
@property (nonatomic, strong)NSString* vungleAppID;
@property (nonatomic) NSString *placementID;
@property (nonatomic) NSArray *allPlacementIDs;
@property (nonatomic) BOOL isNeedToStartAd;

@end

@implementation MovieReward6006

//課題：ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return VungleSDKVersion;
}

- (id)init{
    self = [super init];
    if(self){
        _allPlacementIDs = [NSArray new];
        _isNeedToStartAd = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6006 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.vungleAppID = self.vungleAppID;
        newSelf.placementID = self.placementID;
        newSelf.allPlacementIDs = self.allPlacementIDs;
        newSelf.isNeedToStartAd = self.isNeedToStartAd;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    NSLog(@"data : %@",data);
    
    NSString* vungleAppID = [data objectForKey:@"application_id"];
    if (vungleAppID != nil && ![vungleAppID isEqual:[NSNull null]]) {
        self.vungleAppID = [[NSString alloc] initWithString:vungleAppID];
    }
    NSString *placementID = [data objectForKey:@"placement_reference_id"];
    if (placementID && ![placementID isEqual:[NSNull null]]) {
        self.placementID = [NSString stringWithString:placementID];
    }
    NSArray *placementIDs = [data objectForKey:@"all_placements"];
    if (placementIDs) {
        self.allPlacementIDs = [NSArray arrayWithArray:placementIDs];
    }

    if (self.vungleAppID == nil || self.placementID == nil) {
        NSLog(@"%s Vungle data is invalid", __PRETTY_FUNCTION__);
        return;
    }
    if (self.allPlacementIDs.count == 0) {
        self.allPlacementIDs = @[self.placementID];
    }
}

- (void)initVungle {
    if ([VungleSDK sharedSDK].isInitialized) {
        return;
    }
    NSError *error;
    if (![[VungleSDK sharedSDK] startWithAppId:self.vungleAppID error:&error]) {
        NSLog(@"Error while starting VungleSDK %@", [error localizedDescription]);
    }
}

-(void)initAdnetworkIfNeeded {
    MovieDelegate6006 *delegate = [MovieDelegate6006 sharedInstance];
    [delegate setMovieReward:self inZone:self.placementID];
    [[VungleSDK sharedSDK] setDelegate:delegate];
    [[VungleSDK sharedSDK] setLoggingEnabled:YES];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initVungle];
    });
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    VungleSDK *sdk = [VungleSDK sharedSDK];
    if (!sdk.initialized) {
        self.isNeedToStartAd = YES;
        return;
    }

    [[MovieDelegate6006 sharedInstance] setDelegate:self.delegate inZone:self.placementID];
    NSError *error = nil;
    if (![sdk loadPlacementWithID:self.placementID error:&error]) {
        NSLog(@"Unable to load vungle placement with reference ID :%@, Error %@", self.placementID, error.localizedDescription);
    }
}

-(BOOL)isPrepared{
    id delegate = [[MovieDelegate6006 sharedInstance] getDelegateWithZone:self.placementID];
    if (!delegate) {
        return NO;
    }
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementID];
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError* error;

    //[VUNGLESDK] WARNING: The topmost presented ViewController <XXX> is not equal to the one being passed to the `playAd` method <YYY>
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [sdk playAd:topMostViewController options:nil placementID:self.placementID error:&error];
    }

    if (topMostViewController == nil || error) {
        NSLog(@"Error encountered playing ad : %@", error);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                if (error) {
                    [self setErrorWithMessage:error.localizedDescription code:error.code];
                }
                [self.delegate AdsPlayFailed:self];
            } else {
                NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError* error;
    
    [sdk playAd:viewController options:nil placementID:self.placementID error:&error];
    
    if (error) {
        NSLog(@"Error encountered playing ad : %@", error);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self.delegate AdsPlayFailed:self];
            } else {
                NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    NSLog(@"MovieReward6006 isClassReference");
    Class clazz = NSClassFromString(@"VungleSDK");
    if (clazz) {
        NSLog(@"Found Class: Vungle");
    }
    else {
        NSLog(@"Not found Class: Vungle");
        return NO;
    }
    return YES;
}


/**
 *  広告の読み込みを中止
 */
-(void)cancel
{
    NSLog(@"MovieReward6006 cancel");
    // VungleSDK には対象の処理が無いため何もしない
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [sdk updateConsentStatus:hasUserConsent ? VungleConsentAccepted : VungleConsentDenied consentMessageVersion:@"1.0.0"];
}

- (void)dealloc{
    if(_vungleAppID){
        _vungleAppID = nil;
    }
}

@end


@implementation MovieDelegate6006

+ (instancetype)sharedInstance {
    static MovieDelegate6006 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (void)dealloc {
    [[VungleSDK sharedSDK] setDelegate:nil];
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKDidInitialize {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *movieRewardList = [self getAllMovieReward];
    [movieRewardList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MovieReward6006 *  _Nonnull movieReward, BOOL * _Nonnull stop) {
        if (movieReward.isNeedToStartAd) {
            [movieReward startAd];
            movieReward.isNeedToStartAd = NO;
        }
    }];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

//Vungle delegate
/** 広告準備完了 */
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID {
    NSLog(@"%s isAdPlayable: %@ placementID: %@", __PRETTY_FUNCTION__, (isAdPlayable ? @"YES" : @"NO"), placementID);
    NSLog(@"%@", [[VungleSDK sharedSDK] debugInfo]);

    id delegate = [self getDelegateWithZone:placementID];
    MovieReward6006 *movieReward = (MovieReward6006 *)[self getMovieRewardWithZone:placementID];

    if(isAdPlayable){
        // 広告準備完了
        if (delegate) {
            if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
                [delegate AdsFetchCompleted:movieReward];
            } else {
                NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

/** 動画再生開始 */
- (void)vungleWillShowAdForPlacementID:(NSString *)placementID {
    NSLog(@"%s placementID: %@", __PRETTY_FUNCTION__, placementID);
    id delegate = [self getDelegateWithZone:placementID];
    MovieReward6006 *movieReward = (MovieReward6006 *)[self getMovieRewardWithZone:placementID];

    if (delegate) {
        if ([delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [delegate AdsDidShow:movieReward];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

/** 動画再生終了&エンドカード終了 */
- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID {
    NSLog(@"%s placementID: %@", __PRETTY_FUNCTION__, placementID);
    id delegate = [self getDelegateWithZone:placementID];
    MovieReward6006 *movieReward = (MovieReward6006 *)[self getMovieRewardWithZone:placementID];
    if (delegate) {
        if (info.completedView) {
            BOOL isCompleted = [info.completedView boolValue];
            if (isCompleted) {
                if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                    [delegate AdsDidCompleteShow:movieReward];
                } else {
                    NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
                }
            } else {
                //リワード広告だったら再生エラー
                //リワード広告以外（インタースティシャル）だったらスキップ
                if ([movieReward isMemberOfClass:[MovieReward6006 class]]) {
                    if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                        [delegate AdsPlayFailed:movieReward];
                    } else {
                        NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
                    }
                }
            }
        }
        if ([delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [delegate AdsDidHide:movieReward];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

@end
