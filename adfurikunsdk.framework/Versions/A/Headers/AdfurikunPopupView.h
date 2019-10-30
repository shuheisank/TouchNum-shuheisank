//
//  AdfurikunPopupView.h
//
//  Copyright (c) Terajima Joho Kikaku Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import "adfurikunView.h"
#import "AdfurikunInterfaceView.h"


@protocol AdfurikunPopupViewDelegate;
@class AdfurikunPopupView;

#define ADFRJS_POPUPVIEW_SIZE_300x300 CGSizeMake( 310, 300 )
#define ADFRJS_POPUPVIEW_SIZE_320x480 CGSizeMake( 320, 480 )

enum {
    AdfurikunPopUpCloseTypeTouchUpButton = 100, // 「閉じる」ボタン押下時
    AdfurikunPopUpCloseTypeScheduleSkip,        // 表示頻度のため閉じる
    AdfurikunPopUpCloseTypeMaxDisplay,          // 最大表示回数のため閉じる
    AdfurikunPopUpCloseTypeNetworkFailed,       // ネットワークの未接続
    AdfurikunPopUpCloseTypeAdInfoFailed,        // 広告情報が取得出来ない
};


@interface AdfurikunPopupView : AdfurikunBaseView


//@property(nonatomic,retain) NSString *appID;
@property(nonatomic, assign) NSObject<AdfurikunPopupViewDelegate> *delegate;
@property (nonatomic) int closeType;
@property (nonatomic, assign) int intersAdType; // 現在inmobiのみ広告サイズをいざというときに変更できるように。
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UIImageView *titleImageView;
@property (nonatomic, retain) UIColor *borderColor;

@property (nonatomic, retain) UIView *adBaseView; // 広告表示の枠View
@property (nonatomic, retain) UIView *backgroundView; // タッチブロックしている灰色のView
//@property
/**
 * 広告表示を開始する。
 */
-(void)startShowAd;

/**
 * アドネットワークキーを表示する際等に
 *
 */
-(void)testModeEnable;
-(void)testModeDisable;

/**
 * スケジュールの設定
 * n回に1回表示するタイミング設定（1にすると毎回表示されます）
 * デフォルト 1
 */
-(void) setSchedule:(int)schedule;
-(int) getSchedule;

/**
 * 何回目に表示するか
 * 1回目の表示をn回目にするか(3にすると３回目から表示、0やscheculeを超える数値にすると表示されなくなります。)
 * デフォルト1
 *
 */
-(void) setScheduleFirst:(int)scheduleFirst;
-(int) getScheduleFirst;



/**
 * 最大表示回数
 *
 */
-(void) setMaxDisplay:(int)maxDisplay;
-(int) getMaxDisplay;

// 現在の表示回数
-(int) getDisplayCount;
-(void) setDisplayCount:(int)displayCount; // 現在の広告表示回数を設定する（初期化等に使用可能）

/* 先読み機能
 * 通常(startShowAd)は広告情報取得->内部表示処理->画面反映という流れだが
 * preloadAd : 広告情報取得(取得済みならSkip) -> 内部表示処理
 * preloadShowAd : 画面反映処理
 * と処理を分ける事が出来る。
 */
-(void)preloadAd;
-(void) preloadShowAd;


-(void) setBarGradient:(UIColor*) startColor endColor:(UIColor *)endColor;

/**
 * デザインのカスタマイズを自由に行いたいという要望がありましたので、
 * 閉じる処理と広告表示のビューを取得する処理を公開としています。
 *
 *
 */
- (void)pushCloseButton:(id)sender;
-(AdfurikunInterfaceView *)getIntersAdWebView;


/**
 *  表示する独自広告を追加する。
 *
 *  @param adfurikunViewStr 表示するAdfurikunInterfaceView を継承したクラス名称
 *  @param rate 表示する表示する頻度 1を100%とした少数
 */
-(void)addAdfurikunInterfaceView:(NSString *)adfurikunViewStr rate:(float)rate;

@end

@protocol AdfurikunPopupViewDelegate
@optional

/**
 * 広告の読み込みが完了した通知
 *
 */
-(void)adfurikunViewDidFinishLoadAdData:(AdfurikunPopupView *)view;

/**
 * 広告の表示/更新完了通知
 */
-(void)adfurikunViewDidFinishLoad:(AdfurikunPopupView *)view;

/**
 * 広告がクリックされたことの通知
 */
-(void)adfurikunViewAdTapped:(AdfurikunPopupView *)view;

/**
 * 広告情報の取得に失敗した場合
 *
 */
-(void)adfurikunViewAdFailed:(AdfurikunPopupView *)view;

/**
 * 広告が閉じられた場合
 *
 */
-(void)adfurikunViewAdClose:(AdfurikunPopupView *)view;

@end
