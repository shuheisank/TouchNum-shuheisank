//
//  AdfurikunNativeInfo.h
//
//  Copyright (c) Terajima Joho Kikaku Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdfurikunNativeAdInfo : NSObject
@property (nonatomic, strong, readwrite) NSString *img_url;
@property (nonatomic, strong, readwrite) NSString *link_url;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *text;
@property (nonatomic, strong, readwrite) NSString *clickURL;

/**
 Gunosyなどでタップ時にURLに置換処理を行うURLの際に使用
 */
@property (nonatomic, strong, readwrite) NSMutableURLRequest* clickRequest;

-(void)recClick;

/**
 *  自身のインスタンスを返却する
 *
 *  @return AdfurikunNativeAdInfo *　自分自身のインスタンス
 */
+ (AdfurikunNativeAdInfo *)makeInstance;
@end
