//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import <FiveAd/FiveAd.h>

#define kRetryTimeForNoCache 30.0

@interface MovieInterstitial6008()<FADDelegate>
@property (nonatomic)FADInterstitial *interstitial;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL isReplay;
@property (nonatomic)BOOL didRetryForNoCache;

@end

@implementation MovieInterstitial6008

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return FADSettings.version;
}

-(id)init
{
    self = [super init];
    return self;
}

/**
 *  データの設定
 *
 */
-(void)setData:(NSDictionary *)data
{
    self.fiveAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    self.fiveSlotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"slot_id"]];
    self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    self.submittedPackageName = [data objectForKey:@"package_name"];
}

-(BOOL)isPrepared{
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF][Five]アプリのバンドルIDが、申請されたものと異なります。");
    }
    
    if (self.interstitial) {
        return self.interstitial.state == kFADStateLoaded;
    }
    return NO;
}

-(void)initAdnetworkIfNeeded {
    if ([self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        [MovieConfigure6008 configureWithAppId:self.fiveAppId isTest:self.testFlg];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (self.interstitial) {
        if (self.interstitial.state == kFADStateShowing) {
            return;
        }
        self.interstitial = nil;
    }
    self.interstitial = [[FADInterstitial alloc] initWithSlotId:self.fiveSlotId];
    self.interstitial.delegate = self;

    [self.interstitial loadAdAsync];
}


/**
 *  広告の表示を行う
 */
-(void)showAd
{
    BOOL res = [self.interstitial show];
    if (!res) {
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

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 *
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"FADInterstitial");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FiveAd");
        return NO;
    }
    return YES;
}

-(void)dealloc{
}

/**
 *  広告の読み込みを中止
 *
 */
-(void)cancel
{
}

// ------------------------------ -----------------
// ここからはFiveのDelegateを受け取る箇所
#pragma mark -  FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
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

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:nil code:errorCode];
            [self.delegate AdsFetchError:self];
            NSLog(@"Five SDK %s Errorcode:%ld, slotId : %@", __func__, errorCode, self.fiveSlotId);
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }

    if (errorCode == kFADErrorNoCachedAd && self.didRetryForNoCache == false) {
        self.didRetryForNoCache = true;
        MovieInterstitial6008 __weak *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRetryTimeForNoCache * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf startAd];
        });
    }
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidStart:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = NO;

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

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = YES;
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    if (!self.isReplay) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                [self.delegate AdsDidCompleteShow:self];
            } else {
                NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}


@end

@implementation MovieConfigure6008
+ (void)configureWithAppId:(NSString *)fiveAppId isTest:(BOOL)isTest {
    static dispatch_once_t adfFiveOnceToken;
    dispatch_once_on_main_thread(&adfFiveOnceToken, ^{
        FADConfig *config = [[FADConfig alloc] initWithAppId:fiveAppId];
        config.fiveAdFormat = [NSSet setWithObjects:
                               [NSNumber numberWithInt:kFADFormatVideoReward],
                               [NSNumber numberWithInt:kFADFormatW320H180],
                               nil];
        if (isTest) {
            config.isTest =  YES;
        }

        if (![FADSettings isConfigRegistered]) {
            [FADSettings registerConfig:config];
        }
    });
}

void dispatch_once_on_main_thread(dispatch_once_t *predicate,
                                  dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        dispatch_once(predicate, block);
    } else {
        if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dispatch_once(predicate, block);
            });
        }
    }
}
@end

