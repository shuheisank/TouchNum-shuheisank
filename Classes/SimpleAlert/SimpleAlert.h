//
//  SimpleAlert.h
//
//  Created by Yoichi Onodera@tekunodo on 12/12/26.
//  Copyright (c) 2012 tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	初期化でdelegateとselectorを指定した場合、selectorにbuttonIndexをNSNumberで返却
//	以下、selectorの例
//
//	- (void)hogehogeHundler:(NSNumber *)buttonIndex {
//		if([buttonIndex intValue] == 0) {
//			// Cancel
//		} else
//		if([buttonIndex intValue] == 1) {
//			// OK
//		}
//	}
//------------------------------------------------------------------------------
//	UPDATE	:	12/12/26	Yoichi Onodera		EasyAlertを改良
//				YY/MM/DD	name				content
//
#import <UIKit/UIKit.h>

@interface SimpleAlert : UIAlertView
// 初期化
- (id)initWith:(id)delegate selector:(SEL)selector;

// 表示(buttonsは複数指定可)
- (void)show:(NSString *)title message:(NSString *)message buttons:(NSString *)buttons, ... NS_REQUIRES_NIL_TERMINATION;

// 隠す
- (void)hide;

// 表示状態(YES/NO)
- (BOOL)state;
@end


