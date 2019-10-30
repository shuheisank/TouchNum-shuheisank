//
//  NetworkAvailable.h
//
//  Created by  on 12/09/13.
//  Copyright (c) 2012 YoichiOnodera@tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/09/13	Yoichi Onodera	新規作成
//				12/11/06	Yoichi Onodera	typeを追加
//

#import "NetworkAvailable.h"


@implementation NetworkAvailable

//------------------------------------------------------------------------------
//	ネットワークが使用可能かを判断する
//------------------------------------------------------------------------------
+ (BOOL)state {
	BOOL result = NO;

	Reachability *reach	 = [Reachability reachabilityForInternetConnection];
	[reach startNotifier];

    NetworkStatus netStatus	= [reach currentReachabilityStatus];	
	[reach stopNotifier];

	if(netStatus != NotReachable) {
		 result = YES;
	}

#ifdef DEBUG
NSLog(@"%s:%d", __FUNCTION__, result);
#endif
	return result;
}


//------------------------------------------------------------------------------
//	ネットワークが使用可能かを判断する
//	NOTE : 利用できる場合は種別を返す
//------------------------------------------------------------------------------
+ (NSString *)type {
	Reachability	*reachability	= [Reachability reachabilityWithHostName:@"tekunodo.jp"];
	NetworkStatus	status			= [reachability currentReachabilityStatus];
	NSString		*result;

	if(status == ReachableViaWiFi) {
		result = @"WIFI";
	} else if (status == ReachableViaWWAN) {
		result = @"3G_4G";
	} else if (status == NotReachable) {
		result = @"NONE";
	}

#ifdef DEBUG
NSLog(@"%s:%@", __FUNCTION__, result);
#endif
	return result;
}

@end
