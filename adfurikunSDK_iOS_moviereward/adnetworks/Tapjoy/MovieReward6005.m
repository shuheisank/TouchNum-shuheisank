//
//  MovieReward6005.m (Tapjoy)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6005.h"

#import <Tapjoy/Tapjoy.h>

#define ADAPTER_CLASS_NAME NSStringFromClass(self.class)

@interface MovieReward6005()
@property (nonatomic, assign)BOOL test_flg;
@property (nonatomic, strong)NSString* placement_id;
@property (nonatomic, strong)NSString* sdkKey;
@property (nonatomic, strong)TJPlacement* p;
@property (nonatomic) BOOL isNeedStartAd;
@property (nonatomic) BOOL isConnectionFail;

@end

@implementation MovieReward6005

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return Tapjoy.getVersion;
}

- (id)init {
    NSLog(@"%@ init", ADAPTER_CLASS_NAME);
    self = [super init];
    if (self) {
        _p = nil;
        _isNeedStartAd = NO;
        _isConnectionFail = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6005 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.p = self.p;
        newSelf.isNeedStartAd = self.isNeedStartAd;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    self.placement_id = [data objectForKey:@"placement_id"];
    
    BOOL testFlg = [[data objectForKey:@"test_flg"] boolValue];
    if (testFlg) {
        [Tapjoy setDebugEnabled:testFlg];
    }
    
    self.sdkKey = [data objectForKey:@"sdk_key"];
}

-(void)initAdnetworkIfNeeded {
    //NSLog(@"%@ startAd", ADAPTER_CLASS_NAME);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up success and failure notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectSuccess:)
                                                     name:TJC_LIMITED_CONNECT_SUCCESS
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectFail:)
                                                     name:TJC_LIMITED_CONNECT_FAILED
                                                   object:nil];

        [Tapjoy limitedConnect:self.sdkKey];
    });
    NSLog(@"%@ connectSetting end", ADAPTER_CLASS_NAME);
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (!_p) {
        if (![Tapjoy isLimitedConnected]) {
            self.isNeedStartAd = YES;

            if (self.isConnectionFail) {
                [Tapjoy limitedConnect:self.sdkKey];
            }

            return;
        }

        MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
        [delegate setMovieReward:self inZone:self.placement_id];
        [delegate setDelegate:self.delegate inZone:self.placement_id];

        _p = [TJPlacement limitedPlacementWithName:_placement_id mediationAgent:@"adfully" delegate:delegate];
        _p.videoDelegate = delegate;
        _p.adapterVersion = @"1.0.1";
    }
    [_p requestContent];
}

-(BOOL)isPrepared {
    if (!_p) {
        return NO;
    }
    if ([_p isKindOfClass:[TJPlacement class]]) {
        return _p.isContentAvailable && _p.isContentReady;
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    NSLog(@"%@ showAd", ADAPTER_CLASS_NAME);
    [_p showContentWithViewController:nil];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    NSLog(@"%@ showAdWithPresentingViewController", ADAPTER_CLASS_NAME);
    //引数に nil を渡すと弊社SDK側で再前面、全画面の View を推定して表示します。
    //多くの場合にはこれで正常に動作するのですが、View階層が複雑な場合は指定していただく必要があるケースも出ています。
    if (_p.isContentAvailable) {
        //渡したviewControllerを強制的にご利用したい場合、必ずテストしてください。
        [_p showContentWithViewController:viewController];
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"%@ isClassReference", ADAPTER_CLASS_NAME);
    Class clazz = NSClassFromString(@"Tapjoy");
    if (clazz) {
        NSLog(@"found Class: Tapjoy");
    }
    else {
        NSLog(@"Not found Class: Tapjoy");
        return NO;
    }
    return YES;
}


/**
 *  広告の読み込みを中止
 */
-(void)cancel {
    NSLog(@"%@ cancel", ADAPTER_CLASS_NAME);
    // Tapjoy には対象の処理が無いため何もしない
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [Tapjoy setUserConsent:hasUserConsent ? @"1" : @"0"];
}

-(void)dealloc {
    if(_p != nil){
        _p = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-----------------AppDelegate内の処理を移動--------------------------------------
-(void)tjcConnectSuccess:(NSNotification*)notifyObj {
    NSLog(@"%@ Tapjoy connect Succeeded", ADAPTER_CLASS_NAME);
    if (self.isNeedStartAd) {
        [self startAd];
    }
    self.isConnectionFail = NO;
}

- (void)tjcConnectFail:(NSNotification*)notifyObj {
    NSLog(@"%@ Tapjoy connect Failed", ADAPTER_CLASS_NAME);
    self.isConnectionFail = YES;
}

@end


@interface MovieDelegate6005()
@end

@implementation MovieDelegate6005

+ (instancetype)sharedInstance {
    static MovieDelegate6005 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (void)performAdsFetchError:(TJPlacement *)placement error:(NSError *)error {
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsFetchError:)]) {
            if (error) {
                [movieReward setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [delegate AdsFetchError:movieReward];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

#pragma mark - TJPlacementDelegate

// SDKがTapjoyのサーバーにコンタクトした際に呼ばれます。但し、必ずしもコンテンツを利用可能であることを意味する訳ではありません。
- (void)requestDidSucceed:(TJPlacement*)placement {
    NSLog(@"%@ requestDidSucceed", ADAPTER_CLASS_NAME);
    NSLog(@"isContentAvailable : %d", placement.isContentAvailable);
    if (!placement.isContentAvailable) { // Loading失敗のケースあり
        [self performAdsFetchError:placement error:nil];
    }
}

// Tapjoyのサーバーにコネクトする途中で問題が発生した際に呼ばれます。
- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error {
    NSLog(@"%@ requestDidFail", ADAPTER_CLASS_NAME);
    [self performAdsFetchError:placement error:error];
}

// コンテンツが表示可能となった際に呼ばれます。
- (void)contentIsReady:(TJPlacement*)placement {
    NSLog(@"%@ contentIsReady", ADAPTER_CLASS_NAME);
    // 広告準備完了
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [delegate AdsFetchCompleted:movieReward];
        } else {
            NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

// コンテンツが表示される際に呼ばれます。
- (void)contentDidAppear:(TJPlacement*)placement {
    NSLog(@"%@ contentDidAppear", ADAPTER_CLASS_NAME);
    
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if(delegate && movieReward){
        if([delegate respondsToSelector:@selector(AdsDidShow:)]){
            [delegate AdsDidShow:movieReward];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

// コンテンツが退去される際に呼ばれます。
- (void)contentDidDisappear:(TJPlacement*)placement {
    NSLog(@"%@ contentDidDisappear", ADAPTER_CLASS_NAME);
    
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
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

#pragma mark - TJPlacementVideoDelegate

- (void)videoDidStart:(TJPlacement *)placement {
    NSLog(@"%@ videoDidStart", ADAPTER_CLASS_NAME);
}

/** 動画を最後まで視聴した際に呼ばれます。 */
- (void)videoDidComplete:(TJPlacement *)placement {
    NSLog(@"%@ videoDidComplete", ADAPTER_CLASS_NAME);
    
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [delegate AdsDidCompleteShow:movieReward];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMsg {
    NSLog(@"TJCVideoAdDelegate::videoAdError %@", errorMsg);
    
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [movieReward setErrorWithMessage:errorMsg code:0];
            [delegate AdsPlayFailed:movieReward];
        } else {
            NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate && movieReward is not setting", __FUNCTION__);
    }
}

@end

