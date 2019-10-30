//
//  MovieReward6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/05.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6016.h"

@interface MovieReward6016()

@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) FBRewardedVideoAd* rewardedVideoAd;
@property (nonatomic) BOOL isAnimated;

@end

@implementation MovieReward6016

- (void)setData:(NSDictionary *)data {
    NSString *placementId = [NSString stringWithFormat:@"%@", [data objectForKey:@"placement_id"]];
    if (placementId && ![placementId isEqual:[NSNull null]]) {
        self.placementId = placementId;
        NSInteger animatedValue = [[data valueForKey:@"is_animated"] integerValue];
        self.isAnimated = animatedValue == 1 ? YES : NO;
    }
}

- (void)startAd {
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.placementId];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

-(BOOL)isClassReference {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        return NO;
    }

    Class clazz = NSClassFromString(@"FBRewardedVideoAd");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FBRewardedVideoAd");
        return NO;
    }
    return YES;
}

- (BOOL)isPrepared {
    if (self.delegate && self.rewardedVideoAd && self.rewardedVideoAd.isAdValid) {
        return YES;
    } else {
        return NO;
    }
}

-(void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [self showAdWithPresentingViewController: topMostViewController];
    } else {
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

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if ([self isPrepared]) {
        if (viewController) {
            [self.rewardedVideoAd showAdFromRootViewController:viewController animated:self.isAnimated];
        } else {
            NSLog(@"Error encountered playing ad : viewController cannot be nil");
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
}

#pragma mark - FBRewardedVideoAd delegates
- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        } else {
            NSLog(@"adsFetchCompleted is not responding");
        }
    } else {
        NSLog(@"adsFetchCompleted is not set");
    }
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"MovieReward6016: reward video loading failed \n%@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"adsFetchError is not responding");
        }
    } else {
        NSLog(@"AdsFetchError is not set");
    }
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"adsDidCompleteShow is not responding");
        }
    } else {
        NSLog(@"adsDidCompleteShow is not set");
    }
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    self.rewardedVideoAd = nil;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"adsDidHide is not responding");
        }
    } else {
        NSLog(@"adsDidHide is not set");
    }

}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"adsDidShow is not responding");
        }
    } else {
        NSLog(@"adsDidShow is not set");
    }
}

@end

