//
//  MovieInterstitial6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/14.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieInterstitial6016.h"

@interface MovieInterstitial6016()

@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) FBInterstitialAd* interstitialVideoAd;

@end

@implementation MovieInterstitial6016

- (void)setData:(NSDictionary *)data {
    NSString *placementId = [NSString stringWithFormat:@"%@", [data objectForKey:@"placement_id"]];
    if (placementId && ![placementId isEqual:[NSNull null]]) {
        self.placementId = placementId;
    }
}

- (void)startAd {
    self.interstitialVideoAd = [[FBInterstitialAd alloc] initWithPlacementID:self.placementId];
    self.interstitialVideoAd.delegate = self;
    [self.interstitialVideoAd loadAd];
}

-(BOOL)isClassReference {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        return NO;
    }

    Class clazz = NSClassFromString(@"FBInterstitialAd");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FBInterstitialAd");
        return NO;
    }
    return YES;
}

- (BOOL)isPrepared {
    if (self.delegate && self.interstitialVideoAd && self.interstitialVideoAd.isAdValid) {
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
            [self.interstitialVideoAd showAdFromRootViewController:viewController];
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

#pragma mark - FBInterstitialAd delegates
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
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

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"MovieInterstitial6016: interstitial video loading failed \n%@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"adsFetchError is not responding");
        }
    } else {
        NSLog(@"adsFetchError is not set");
    }
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    self.interstitialVideoAd = nil;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"AdsDidCompleteShow is not responding");
        }
    } else {
        NSLog(@"AdsDidCompleteShow is not set");
    }
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"AdsDidHide is not responding");
        }
    } else {
        NSLog(@"AdsDidHide is not set");
    }
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
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

