//
//  NetworkAvailable.h
//
//  Created by  on 12/09/13.
//  Copyright (c) 2012 YoichiOnodera@tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/09/13	Yoichi Onodera	新規作成
//				12/09/25	Yoichi Onodera	Reachability.hのimport先変更
//				12/11/06	Yoichi Onodera	typeを追加
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class Reachability;

@interface NetworkAvailable : NSObject

//	ネットワークが使用可不可を判断する
+ (BOOL)state;

//	ネットワーク種別をを判断する(2012/11/06現在は、なし(NONE)、3G or 4G(3G_4G)、Wi-Fi(WIFI)のみ)
+ (NSString *)type;

@end

