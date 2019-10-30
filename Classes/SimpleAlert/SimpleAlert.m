//
//  SimpleAlert.m
//
//  Created by Yoichi Onodera@tekunodo on 12/12/26.
//  Copyright (c) 2012 tekunodo. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/12/26	Yoichi Onodera		EasyAlertを改良
//				YY/MM/DD	name				content
//

#import "SimpleAlert.h"

//------------------------------------------------------------------------------
@interface SimpleAlert() {
	UIAlertView	*alert;
	id			ownerDelegate;
	SEL			ownerSelector;
}
- (void)releaseAlert;
@end


//------------------------------------------------------------------------------
@implementation SimpleAlert

#pragma mark - Interface
//------------------------------------------------------------------------------
//	初期化
//------------------------------------------------------------------------------
- (id)initWith:(id)delegate selector:(SEL)selector {
	self = [super init];

	if(self != nil) {
		ownerDelegate	= delegate;
		ownerSelector	= selector;
		alert			= nil;
	}
	return self;
}


//------------------------------------------------------------------------------
//	表示
//------------------------------------------------------------------------------
- (void)show:(NSString *)title message:(NSString *)message buttons:(NSString *)buttons, ... {
	if(alert == nil) {
		alert = [
			[UIAlertView alloc]
			initWithTitle		: title 
			message				: message
			delegate			: self
			cancelButtonTitle	: nil	// ここでボタンは追加しない
			otherButtonTitles	: nil	// ここでボタンは追加しない
		];
		NSString	*value = buttons;
		va_list		arg;

		// ここでボタンを追加する
		va_start(arg, buttons);
		{
			while(value) {
				[alert addButtonWithTitle:value];
				value = va_arg(arg, NSString *);
			}
		}
		va_end(arg);
		[alert show];
	}
}


//------------------------------------------------------------------------------
//	非表示
//------------------------------------------------------------------------------
- (void)hide {
	if(alert != nil) {
		[alert dismissWithClickedButtonIndex:0 animated:YES];
	}
}


//------------------------------------------------------------------------------
//	アラートの表示状態取得
//------------------------------------------------------------------------------
- (BOOL)state {
	return ((alert != nil) ? YES : NO);
}


#pragma mark - Private
//------------------------------------------------------------------------------
//	解放
//------------------------------------------------------------------------------
- (void)dealloc {
	[self releaseAlert];
}


//------------------------------------------------------------------------------
//	UIAlertViewの解放
//------------------------------------------------------------------------------
- (void)releaseAlert {
	if(alert != nil) {
		alert = nil;
	}
}


#pragma mark - UIAlertView Delegate
//------------------------------------------------------------------------------
//	ボタン押下時、delegateとselectorの指定があればownerへ通知
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(ownerDelegate != nil && ownerSelector != nil) {
		[ownerDelegate performSelector:ownerSelector withObject:[NSNumber numberWithInt:buttonIndex]];
	}
}


//------------------------------------------------------------------------------
//	ボタン押下時、またはhideEasyAlertが呼ばれた時
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self releaseAlert];	// UIAlertViewの解放
}


@end
