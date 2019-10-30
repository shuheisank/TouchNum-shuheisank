//
//  AdfurikunView.h
//  adfurikunsdk
//
//  Copyright (c) Terajima Joho Kikaku Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import "AdfurikunInterfaceView.h"



@protocol AdfurikunViewDelegate;
@class AdfurikunView;

#define ADFRJS_VIEW_SIZE_320x50 CGSizeMake( 320.0, 50.0 )
enum {
    AdfurikunViewAnimationTransitionNone = 0,
    AdfurikunViewAnimationTransitionFlipFromLeft = UIViewAnimationOptionTransitionFlipFromLeft,
    AdfurikunViewAnimationTransitionFlipFromRight = UIViewAnimationOptionTransitionFlipFromRight,
    AdfurikunViewAnimationTransitionCurlUp = UIViewAnimationOptionTransitionCurlUp,
    AdfurikunViewAnimationTransitionCurlDown = UIViewAnimationOptionTransitionCurlDown,
    AdfurikunViewAnimationTransitionFadeIn,
    AdfurikunViewAnimationTransitionFadeOut,
    AdfurikunViewAnimationTransitionRandom,
    AdfurikunViewAnimationTransitionCustom,
};

@interface AdfurikunBaseView : UIView

@property(nonatomic,retain) NSString *appID;

/**
 * AppId の設定
 */
-(void) setAppId:(NSString *)app_id;
-(NSString*) getAppId;

@end


@interface AdfurikunView : AdfurikunBaseView

@property(nonatomic, assign) NSObject<AdfurikunViewDelegate> *delegate;
@property(nonatomic, assign) UIViewAnimationOptions transitionType;
@property(nonatomic, assign) float transitionDulation;
@property(nonatomic, assign) id customAnimationCalss; // 綴りミスが発覚したので、正しい綴りと両方使えるようにしています。
@property(nonatomic, assign) id customAnimationClass;
@property(nonatomic, assign) SEL customAnimationMethod;

//@property
/**
 * 広告表示を開始する。
 */
-(void)startShowAd;
/**
 * タイマーによる広告切り替えなどを停止する
 * 再度startShowAdを呼び出すことで更新は再開される
 * viewController に張ったまま次の viewController へ遷移する際などに。
 */
-(void)stopUpdating;

/**
 * アドネットワークキーを表示する際等に
 *
 */
-(void)testModeEnable;
-(void)testModeDisable;

/**
 * YDN 用のユーザーエージェントにするとき
 *
 */
-(void)setUserAgentYDN;


/**
 *  表示する独自広告を追加する。
 *
 *  @param adfurikunViewStr 表示するAdfurikunInterfaceView を継承したクラス名称
 *  @param rate 表示する表示する頻度 1を100%とした少数
 */
-(void)addAdfurikunInterfaceView:(NSString *)adfurikunViewStr rate:(float)rate;

@end

@protocol AdfurikunViewDelegate
@optional
/**
 * 広告の表示/更新完了通知
 */
-(void)adfurikunViewDidFinishLoad:(AdfurikunView *)view;
/**
 * 広告がクリックされたことの通知
 */
-(void)adfurikunViewAdTapped:(AdfurikunView *)view;

/**
 * 広告情報の取得に失敗した場合
 *
 */
-(void)adfurikunViewAdFailed:(AdfurikunView *)view;


@end


