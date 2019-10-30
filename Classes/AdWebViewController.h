//
//  AdWebViewController.h
//  TouchNumber
//
//  Created by  on 12/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/10/31	Yoichi Onodera		iOS4.3系でtekunodo.ウェブが表示されない不具合修正
//												viewWillAppearの処理を分離 > initAdWebViewを追加
//												Toolbarが機能していないので修正
//												ログ追加
//				YY/MM/DD	Name				Comment
//

#import <UIKit/UIKit.h>
#import "TKND.h"


@interface AdWebViewController : UIViewController <UIWebViewDelegate> {
	CGSize								screenSize;
	CGPoint								screenCenter;

	NSURL								*_url;
	IBOutlet UINavigationItem			*_navigationTitle;

@private
	UIWebView							*webView;
	IBOutlet UINavigationBar			*navigationBar;
	IBOutlet UIToolbar					*toolBar;
	IBOutlet UIActivityIndicatorView	*indicator;

	UIBarButtonItem						*back;
	UIBarButtonItem						*fwd;
}

@property (nonatomic, strong) NSURL				*url;
@property (nonatomic, strong) UINavigationItem	*navigationTitle;

- (id)initWithURL:(NSURL *)url;
- (void)initAdWebView;

@end
