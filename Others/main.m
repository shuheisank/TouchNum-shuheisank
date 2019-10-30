//
//  main.m
//  TouchNumber
//
//  Created by 鎌田 寛昭 on 09/05/13.
//  Copyright 株式会社寺島情報企画 2009. All rights reserved.
//------------------------------------------------------------------------------
//	UPDATE	:	12/12/19	Yoichi Onodera		MainWindow.xib廃止
//				YY/MM/DD	Name				Conte
//

#import <UIKit/UIKit.h>
#import "TouchNumberAppDelegate.h"


//------------------------------------------------------------------------------
int main(int argc, char *argv[]) {
LOG(@"iOS%@", [[UIDevice currentDevice] systemVersion]);

	@autoreleasepool {
		UIApplicationMain(argc, argv, nil, NSStringFromClass([TouchNumberAppDelegate class]));
	}
}
