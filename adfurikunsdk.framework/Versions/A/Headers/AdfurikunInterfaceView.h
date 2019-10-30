//
//  AdfurikunInterfaceView.h
//
//  Copyright (c) Terajima Joho Kikaku Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// 循環参照対策にクラスだよと宣言してます
@protocol AdfurikunViewDelegate;
@class AdfurikunView;


@interface AdfurikunInterfaceView : UIView

@property(nonatomic, assign) NSObject<AdfurikunViewDelegate> *delegate;
@property (nonatomic, strong) AdfurikunView *adfurikunView;

/**
 *  設定データがある場合にはこれをオーバーライド
 *
 */
-(void)setting:(NSDictionary *)settingsData;

/**
 *  表示するかのチェック
 *
 *  @return 表示しない場合はNO, 表示する場合にはYES
 */
-(BOOL) isDisplay;

/**
 *  表示直前に呼び出すチェック
 *
 *  @return 表示しない場合はNO, 表示する場合にはYES
 */
-(BOOL) checkDisplayAd;

/**
 *  表示したことを通知
 */
-(void)postAdDisplayed;

/**
 *  クリックされた事を通知
 */
-(void)postAdClicked;

/**
 *  広告の表示
 */
-(void)loadAd;

/**
 *
 * アニメーション用の機能ViewからContext経由で登録を行う
 *
 */
-(UIImageView *)getScreenImageView;

@end