//
//  MovieReword6004.m
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import "MovieReward6004.h"
#import <Foundation/Foundation.h>

@interface MovieReward6004()

@property (nonatomic, strong) NSString *maioMediaId;
@property (nonatomic, strong) NSString *maioZoneId;
@property (nonatomic, assign) BOOL testFlg;

@end


@implementation MovieReward6004

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return Maio.sdkVersion;
}

-(id)init
{
    self = [super init];
    
    if ( self ) {
    }
    
    return self;
}

-(void)setData:(NSDictionary *)data
{
    self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    
    self.maioMediaId = [NSString stringWithFormat:@"%@", [data objectForKey:@"media_id"]];
    if ([data objectForKey:@"spot_id"]) {
        NSString *spotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"spot_id"]];
        if ([spotId length] > 0) {
            self.maioZoneId = spotId;
        }
    }
    //広告の読み込みがmediaID単位で行われることにより
    //startAdより前にisPrepared=trueになって広告が再生されるケースがあるため
    [[MovieDelegate6004 sharedInstance] setMovieReward:self inZone:self.maioZoneId];
}

- (void)setDelegate:(NSObject<ADFMovieRewardDelegate> *)delegate {
    [[MovieDelegate6004 sharedInstance] setDelegate:delegate inZone:self.maioZoneId];
    [super setDelegate:delegate];
}

-(BOOL)isPrepared{
    if (!self.delegate) {
        NSAssert(NO, @"self.delegate must not be nil");
        return NO;
    }
    if (self.maioZoneId) {
        return [Maio canShowAtZoneId:self.maioZoneId];
    } else {
        return [Maio canShow];
    }
}

-(void)startAd
{
    // 動画の読み込みを開始します。
    static dispatch_once_t adfMaioOnceToken;
    dispatch_once(&adfMaioOnceToken, ^{
        // テストモードに変更（リリース前必ず本番モードに戻してください）
        // [Maio setAdTestMode:YES];
        if(self.testFlg){
            [Maio setAdTestMode:self.testFlg];
        }
        [Maio startWithMediaId:self.maioMediaId delegate:[MovieDelegate6004 sharedInstance]];
    });
}

-(void)showAd
{
    if (self.maioZoneId) {
        if ([Maio canShowAtZoneId:self.maioZoneId]) {
            @try {
                [Maio showAtZoneId:self.maioZoneId];;
            }
            @catch (NSException *exception) {
                NSLog(@"Maio zone id %@ has exception name[%@] description[%@]", self.maioZoneId, exception.name, exception.description);
            }
        }
    } else {
        if ([Maio canShow]) {
            @try {
                [Maio show];
            }
            @catch (NSException *exception) {
                NSLog(@"Maio has exception name[%@] description[%@]", exception.name, exception.description);
            }
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
}

-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"Maio");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: Maio");
        return NO;
    }
    return YES;
}

-(void)cancel
{
    // Maio には対象の処理がないので、何もしない。
}

-(void)dealloc{
    if(_maioMediaId != nil){
        _maioMediaId = nil;
    }
}
@end


@interface MovieDelegate6004()
// zoneIDごとにADFmyMovieRewardInterfaceインスタンスを管理
@property (nonatomic) NSDictionary<NSString *, ADFmyMovieRewardInterface *> *rewardMap;
// zoneIDごとにdelegateを管理
@property (nonatomic) NSDictionary<NSString *, id<ADFMovieRewardDelegate>> *delegateMap;
@end

@implementation MovieDelegate6004

+ (instancetype)sharedInstance {
    static MovieDelegate6004 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rewardMap = [NSDictionary new];
        _delegateMap = [NSDictionary new];
    }
    return self;
}

- (void)setMovieReward:(ADFmyMovieRewardInterface *)movieReward inZone:(NSString *)zoneId {
    NSMutableDictionary *d = [_rewardMap mutableCopy];
    if (!zoneId) {
        zoneId = @"default";
    }
    [d setValue:movieReward forKey:zoneId];
    _rewardMap = d;
}

- (ADFmyMovieRewardInterface *)getMovieRewardWithZone:(NSString *)zoneId {
    if (!zoneId || zoneId.length == 0 || !_rewardMap[zoneId]) {
        zoneId = @"default";
    }
    return _rewardMap[zoneId];
}

- (void)setDelegate:(id<ADFMovieRewardDelegate>)delegate inZone:(NSString *)zoneId {
    if ([_delegateMap isEqual:[NSNull null]]) {
        return;
    }
    NSMutableDictionary *d = [_delegateMap mutableCopy];
    if (!zoneId) {
        zoneId = @"default";
    }
    [d setValue:delegate forKey:zoneId];
    _delegateMap = d;
}

- (id<ADFMovieRewardDelegate>)getDelegateWithZone:(NSString *)zoneId {
    if (!zoneId || zoneId.length == 0 || !_delegateMap[zoneId]) {
        zoneId = @"default";
    }
    return _delegateMap[zoneId];
}

#pragma mark - MaioDelegate

/**
 *  全てのゾーンの広告表示準備が完了したら呼ばれます。
 */
- (void)maioDidInitialize {
    NSLog(@"%s", __func__);
}

/**
 *  広告の配信可能状態が変更されたら呼ばれます。
 *
 *  @param zoneId   広告の配信可能状態が変更されたゾーンの識別子
 *  @param newValue 変更後のゾーンの状態。YES なら配信可能
 */
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    NSLog(@"%s", __func__);
    
    id delegate = [self getDelegateWithZone:zoneId];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
    if (delegate && movieReward) {
        if (newValue) {
            if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
                [delegate AdsFetchCompleted:movieReward];
            } else {
                NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
            }
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

/**
 *  広告が再生される直前に呼ばれます。
 *  最初の再生開始の直前にのみ呼ばれ、リプレイ再生の直前には呼ばれません。
 *
 *  @param zoneId  広告が表示されるゾーンの識別子
 */
- (void)maioWillStartAd:(NSString *)zoneId {
    NSLog(@"%s", __func__);
    
    // WillShow はないので、DidShow で
    id delegate = [self getDelegateWithZone:zoneId];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [delegate AdsDidShow:movieReward];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

/**
 *  広告の再生が終了したら呼ばれます。
 *  最初の再生終了時にのみ呼ばれ、リプレイ再生の終了時には呼ばれません。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 *  @param playtime 動画の再生時間（秒）
 *  @param skipped  動画がスキップされていたら YES、それ以外なら NO
 *  @param rewardParam  ゾーンがリワード型に設定されている場合、予め管理画面にて設定してある任意の文字列パラメータが渡されます。それ以外の場合は nil
 */
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    NSLog(@"%s", __func__);
    
    id delegate = [self getDelegateWithZone:zoneId];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
    if (!skipped && delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [delegate AdsDidCompleteShow:movieReward];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

/**
 *  広告がクリックされ、ストアや外部リンクへ遷移した時に呼ばれます。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 */
- (void)maioDidClickAd:(NSString *)zoneId {
    NSLog(@"%s", __func__);
}

/**
 *  広告が閉じられた際に呼ばれます。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 */
- (void)maioDidCloseAd:(NSString *)zoneId {
    
    NSLog(@"%s", __func__);
    
    id delegate = [self getDelegateWithZone:zoneId];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [delegate AdsDidHide:movieReward];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

/**
 *  SDK でエラーが生じた際に呼ばれます。
 *
 *  @param zoneId  エラーに関連するゾーンの識別子
 *  @param reason   エラーの理由を示す列挙値
 */
- (void)maioDidFail:(NSString *)zoneId reason:(MaioFailReason)reason {
    // ログ表示
    NSLog(@"%s", __func__);
    NSString *faileMessage;
    
    switch ((int)reason) {
        case MaioFailReasonUnknown:
            faileMessage =  @"Unknown";
            break;
        case MaioFailReasonNetworkConnection:
            faileMessage =  @"NetworkConnection";
            break;
        case MaioFailReasonNetworkServer:
            faileMessage =  @"NetworkServer";
            break;
        case MaioFailReasonNetworkClient:
            faileMessage =  @"NetworkClient";
            break;
        case MaioFailReasonSdk:
            faileMessage =  @"Sdk";
            break;
        case MaioFailReasonDownloadCancelled:
            faileMessage =  @"DownloadCancelled";
            break;
        case MaioFailReasonAdStockOut:
            faileMessage =  @"AdStockOut";
            break;
    }
    
    id delegate = [self getDelegateWithZone:zoneId];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
    
    if (delegate && faileMessage) {
        if ([delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [movieReward setErrorWithMessage:faileMessage code:0];
            [delegate AdsFetchError:movieReward];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate and faileMessage is not setting", __FUNCTION__);
    }
    
    if (reason == MaioFailReasonVideoPlayback) {
        faileMessage = @"VideoPlayback";
        if (delegate) {
            if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [delegate AdsPlayFailed:movieReward];
            } else {
                NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
    
    NSLog(@"Maio SDK Error:%@", faileMessage);
}

@end
