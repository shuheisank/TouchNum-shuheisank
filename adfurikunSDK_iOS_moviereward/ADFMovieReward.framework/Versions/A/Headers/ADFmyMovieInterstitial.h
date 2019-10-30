//
//  ADFmyMovieInterstitial.h
//  ADFMovieReword
//
//  Created by Junhua Li on 2016/11/02.
//  (c) 2016 ADFULLY Inc.
//

#import "ADFmyMovieReward.h"

@interface ADFmyMovieInterstitial : NSObject<ADFMovieRewardDelegate>
@property (nonatomic, weak) UIViewController *displayViewController;
@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

+ (BOOL)isSupportedOSVersion;
/**
 初期化関数。initWithAppIDからRenameされました。
 */
+ (void)initializeWithAppID:(NSString *)appID;
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController; __deprecated_msg("Please use 'initializeWithAppID:' instead");
+ (void)initializeWithAppID:(NSString *)appID viewController:(UIViewController*)viewController option:(NSDictionary*)option;
+ (ADFmyMovieInterstitial *)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate; __deprecated_msg("Please use 'initializeWithAppID:option:' instead");
+ (void)disposeAll;

-(BOOL)isPrepared;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 *
 */
-(void)load;
-(void)play;
-(void)playWithCustomParam:(NSDictionary*)param;
-(void)playWithPresentingViewController:(UIViewController *)viewController;
-(void)playWithPresentingViewController:(UIViewController *)viewController customParam:(NSDictionary*)param;
-(void)dispose;

@end
