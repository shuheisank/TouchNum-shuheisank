//
//  adfurikunsdk.h
//  adfurikunsdk (2.10.1)
//
//  Created by tjk on 2015/02/09.
//  Copyright (c) 2015年 tjk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AdfurikunViewDelegate;
@class AdfurikunView;

#define ADFRJS_VIEW_SIZE_320x50 CGSizeMake( 320.0, 50.0 )

@interface AdfurikunSDK : NSObject

+(AdfurikunSDK *)sharedManager;
-(AdfurikunView *)adViewWithFrame:(CGRect)frame
                         delegate:(NSObject<AdfurikunViewDelegate> *)delegateObj;


@end
