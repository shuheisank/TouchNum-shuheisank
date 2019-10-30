//
//
//  MovieReward6010.m(Afio)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6010.h"

@interface MovieReward6010()
@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic) BOOL didLoad;
@end

@implementation MovieReward6010
/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    self.sid = [data objectForKey:@"sid"];
    self.tag = [data objectForKey:@"tag"];
    if (!self.tag || [self.tag isEqual: [NSNull null]]){
        self.tag = @"";
    }
    
    self.didLoad = NO;
}

-(void)initAdnetworkIfNeeded {
    if (!self.amoadInterstitialVideo) {
        self.amoadInterstitialVideo = [AMoAdInterstitialVideo sharedInstanceWithSid:self.sid tag:self.tag];
        [self.amoadInterstitialVideo setDelegate:self];
        [self setCancellable];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    // 動画の読み込みを開始します。
    if (self.amoadInterstitialVideo && !self.amoadInterstitialVideo.isLoaded) {
        [self.amoadInterstitialVideo load];
        self.didLoad = YES;
    }
}

-(BOOL)isPrepared {
    if (self.didLoad && self.delegate && self.amoadInterstitialVideo && self.amoadInterstitialVideo.isLoaded) {
        return YES;
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    if ([self isPrepared]) {
        [self.amoadInterstitialVideo show];
        self.didLoad = NO;
    } else {
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        }
    }
}
-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"AMoAdInterstitialVideo");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: AMoAdInterstitialVideo");
        return NO;
    }
    return YES;
}

-(void)setCancellable {
    if (self.amoadInterstitialVideo) {
        [self.amoadInterstitialVideo setCancellable:NO];
    }
}

#pragma mark - AMoAdInterstitialVideoDelegate
- (void)amoadInterstitialVideo:(AMoAdInterstitialVideo *)amoadInterstitialVideo didLoadAd:(AMoAdResult)result {
    // 広告のロードが完了した
    NSLog(@"%s", __FUNCTION__);
    if (result == AMoAdResultSuccess) {
        NSLog(@"%s %@", __FUNCTION__, @"AMoAdResultSuccess");
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
                [self.delegate AdsFetchCompleted:self];
            } else {
                NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    } else {
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
    
}

- (void)amoadInterstitialVideoDidStart:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 動画の再生を開始した
    NSLog(@"%s", __FUNCTION__);
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

- (void)amoadInterstitialVideoDidComplete:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 動画を最後まで再生完了した
    NSLog(@"%s", __FUNCTION__);
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

- (void)amoadInterstitialVideoDidFailToPlay:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 動画の再生に失敗した
    NSLog(@"%s", __FUNCTION__);
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

- (void)amoadInterstitialVideoDidShow:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 広告を表示した
    NSLog(@"%s", __FUNCTION__);
}

- (void)amoadInterstitialVideoWillDismiss:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 広告を閉じた
    NSLog(@"%s", __FUNCTION__);
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

- (void)amoadInterstitialVideoDidClickAd:(AMoAdInterstitialVideo *)amoadInterstitialVideo {
    // 広告がクリックされた
    NSLog(@"%s", __FUNCTION__);
}
@end
