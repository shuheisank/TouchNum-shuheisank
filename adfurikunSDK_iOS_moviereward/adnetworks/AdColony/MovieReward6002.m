//
//  MovieReward6002.m(AdColony)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6002.h"

@interface MovieReward6002()

@property (nonatomic, strong) NSString *adColonyAppId;
@property (nonatomic, strong) NSArray *adColonyAllZones;
@property (nonatomic, strong) NSString *adShowZoneId;
@property (nonatomic, weak) UIViewController* appViewController;
@property (nonatomic) AdColonyInterstitial *ad;
@property (nonatomic) BOOL hasConfigured;

@end

@implementation MovieReward6002

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return AdColony.getSDKVersion;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        _appViewController = nil;
        _hasConfigured = NO;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6002 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.appViewController = self.appViewController;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    NSString *colonyAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    NSString *colonyZoneId = [NSString stringWithFormat:@"%@", [data objectForKey:@"zone_id"]];
    NSArray *colonyAllZones = [data objectForKey:@"all_zones"];

    _adColonyAppId = colonyAppId;
    _adShowZoneId = colonyZoneId;
    
    _adColonyAllZones = colonyAllZones;
    if (_adColonyAllZones == nil) {
        _adColonyAllZones = @[colonyZoneId];
    }
}

-(BOOL)isPrepared
{
    if (self.delegate && _ad && _ad.expired == NO) {
        return YES;
    }
    return NO;
}

-(void)initAdnetworkIfNeeded {
    // AdColonyの初期化は一度だけしか行わない
    // 初期化が失敗した場合はAdColonyが自分でリトライする
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        AdColonyAppOptions *options = nil;
        if (self.hasGdprConsent != nil) {
            options = [AdColonyAppOptions new];
            options.gdprRequired = self.hasGdprConsent.boolValue;
            options.gdprConsentString = @"gdpr";
        }
        [AdColony configureWithAppID:_adColonyAppId zoneIDs:_adColonyAllZones options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
            _hasConfigured = YES;
            [self requestInterstitial];
        }];
    });
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    // 初期化に成功したら以降はインタースティシャルのリクエストのみ行う
    if (_hasConfigured) {
        [self requestInterstitial];
    }
}

- (void)requestInterstitial {
    [AdColony requestInterstitialInZone:_adShowZoneId options:nil

        // Handler for successful ad requests
        success:^(AdColonyInterstitial * _Nonnull ad) {
            [self onAdFetchCompleted];

            ad.open = ^{
                [self onAdStarted];
            };
            ad.close = ^{
                [self onAdFinished];
            };
            ad.expire = ^{
                _ad = nil;
            };

            _ad = ad;
        }

        // Handler for failed ad requests
        failure:^(AdColonyAdRequestError * _Nonnull error) {
            [self setErrorWithMessage:[error localizedDescription] code:[error code]];

            [self onAdFetchFailed];
            NSLog(@"Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
        }
    ];
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [_ad showWithPresentingViewController:topMostViewController];
    }

    if (topMostViewController == nil) {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
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
 *  広告の表示を行う
 */
-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    // 表示を呼び出す
    if ([self isPrepared]) {
        [_ad showWithPresentingViewController:viewController];
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"AdColony");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: AdColony");
        return NO;
    }
    return YES;
}

-(void)dealloc
{
    if (_adColonyAppId != nil){
        _adColonyAppId = nil;
    }
    if (_adColonyAllZones != nil){
        _adColonyAllZones = nil;
    }
    if (_adShowZoneId != nil){
        _adShowZoneId = nil;
    }
    if (_appViewController != nil){
        _appViewController = nil;
    }
}

/**
 *    広告の読み込みを中止
 */
-(void)cancel
{
    if (_ad) {
        [_ad cancel];
    }
}

- (void)onAdFetchCompleted
{
    NSLog(@"onAdColonyAdAvailabilityChange");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        } else {
            NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)onAdFetchFailed
{
    NSLog(@"onAdColonyAdFetchedError");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)onAdStarted
{
    NSLog(@"onAdColonyAdStarted");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)onAdFinished
{
    NSLog(@"onAdColonyAdFinished");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}
@end
