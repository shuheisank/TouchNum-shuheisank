//
//  MovieReword6004.m
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import "MovieReward6007.h"
@class UIViewController;

@interface MovieReward6007()<SmaadVideoDelegate>
@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, strong) NSString *zoneId;
@end


@implementation MovieReward6007

-(id)init
{
  self = [super init];
  
  if ( self ) {
  }
  
  return self;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
  self.mediaId = [NSString stringWithFormat:@"%@", [data objectForKey:@"media_id"]];
  self.zoneId = [NSString stringWithFormat:@"%@", [data objectForKey:@"zone_id"]];
}


-(BOOL)isPrepared{
  return [[self getInstance] canPlayVideo];
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
  // 動画の読み込みを開始します。
  [[SmaadVideoAd sharedInstance:_zoneId] initWithZoneId:YES delegate:self userId:_mediaId];
  
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
  if ([self isPrepared]) {
    [[self getInstance] playVideoAd];
  }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
  Class clazz = NSClassFromString(@"SmaadVideoAd");
  if (clazz) {
  } else {
    NSLog(@"Not found Class: SmaadVideoAd");
    return NO;
  }
  return YES;
}

-(SmaadVideoAd*)getInstance{
  return [SmaadVideoAd sharedInstance:_zoneId];
}

/**
 *  広告の読み込みを中止
 */
-(void)cancel
{
  // 対象の処理がないので、何もしない。
}

#pragma mark - SmaadVideoDelegate delegate

// 広告枠初期化成功
- (void) didSuccessInit{}

// 広告枠初期化失敗
- (void) didErrorInit{}

// 動画広告再生準備完了
- (void) didReadyVideo{
  if ( self.delegate ) {
    if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
      [self.delegate AdsFetchCompleted:self];
    } else {
      NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
    }
  } else {
    NSLog(@"%s Delegate is not setting", __FUNCTION__);
  }
}

// 動画広告再生開始(リプレイ時は呼ばれない)
- (void) didStartPlayVideo{
  if ( self.delegate ) {
    if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
      [self.delegate AdsDidShow:self];
    } else {
      NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
    }
  } else {
    NSLog(@"%s Delegate is not setting", __FUNCTION__);
  }
}

// 動画広告再生完了(リプレイ時は呼ばれない)
- (void) didCompletePlayVideo:(nonnull NSString *) pay{
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

// エンドカード閉じるボタン押下
- (void) didCloseEndcard{
  if ( self.delegate ) {
    if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
      //閉じた瞬間は準備完了フラグが切り替わってないので、一瞬待つ
      [NSThread sleepForTimeInterval:0.2f];
      [self.delegate AdsDidHide:self];
    } else {
      NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
    }
  } else {
    NSLog(@"%s Delegate is not setting", __FUNCTION__);
  }
}

// 動画広告再生実行時エラー
- (void)didErrorPlayVideo:(SmaadErrorCode)errorCode{
  if ( self.delegate ) {
    if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
      [self setErrorWithMessage:nil code:errorCode];
      [self.delegate AdsPlayFailed:self];
    } else {
      NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
    }
  } else {
    NSLog(@"%s Delegate is not setting", __FUNCTION__);
  }
}

-(void)dealloc{
  
  if(_mediaId != nil){
    _mediaId = nil;
  }
  if(_zoneId != nil){
    [SmaadVideoAd sharedInstance:_zoneId].delegate = nil;
    _zoneId = nil;
  }
}
@end
