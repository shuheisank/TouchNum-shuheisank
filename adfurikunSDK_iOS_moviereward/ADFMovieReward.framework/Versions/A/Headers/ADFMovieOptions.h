//
//  ADFMovieOptions.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2017/06/15.
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 アドフリくん動画リワードSDK アプリユーザの性別
 
 - ADFMovieOptions_Gender_Other     : 不明/その他
 - ADFMovieOptions_Gender_Male      : 男性
 - ADFMovieOptions_Gender_Female    : 女性
 */

typedef NS_ENUM(NSInteger, ADFMovieOptions_Gender) {
    ADFMovieOptions_Gender_Other = 0,
    ADFMovieOptions_Gender_Male = 1,
    ADFMovieOptions_Gender_Female = 2,
};

@interface ADFMovieOptions : NSObject

/**
 *  アプリユーザの性別を指定します。
 *
 *  @param gender アプリユーザの性別
 */
+ (void)setUserGender:(ADFMovieOptions_Gender)gender;

/**
 *  アプリユーザの性別を返却します。
 *
 *  @return setUserGender:で一番直近指定されたアプリユーザの性別
 */
+ (ADFMovieOptions_Gender)getUserGender;

/**
 *  アプリユーザの年齢を指定します。
 *
 *  @param age アプリユーザの年齢
 */
+ (void)setUserAge:(int)age;

/**
 *  アプリユーザの年齢を返却します。
 *
 *  @return setUserAge:で一番直近指定されたアプリユーザの年齢
 */
+ (int)getUserAge;

/**
 *  EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。
 *
 *  @param hasUserConsent:同意をした場合にはTRUEを渡す
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

+ (NSNumber *)getHasUserConsentNumber;

@end
