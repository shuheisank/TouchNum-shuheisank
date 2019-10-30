//
//  GraphAlert.m
//  TouchNumber
//
//  Created by Akihiko Sato on 2013/07/11.
//------------------------------------------------------------------------------
//	UPDATE	                Name				Comment
//
//  ver3.21     13/07/18    Akihiko Sato        Replay Graph 追加
//------------------------------------------------------------------------------

#import "GraphAlert.h"
#import "GraphView.h"

#ifdef FREE_VERSION
// free
#define ALERT_HEIGHT 420.0
#define ALERT_HEIGHT_1ST 480
#else
// pro
#define ALERT_HEIGHT 380.0
#define ALERT_HEIGHT_1ST 440
#endif

#define ALERT_CENTER_X 165.0

@implementation GraphAlert
@synthesize delegate;
@synthesize selector;
@synthesize alert;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//------------------------------------------------------------------------------
//	初期化
//------------------------------------------------------------------------------
- (id)initWithDelegateAndSelector:(id)ownerDelegate selector:(SEL)ownerSelector {
LOG();
	self = [super init];
	
	if(self != nil) {
		
		// 初期化
		delegate	= ownerDelegate;
		selector	= ownerSelector;
		//--------------------------------------------
		// 4inch判別
		if([[UIScreen mainScreen]applicationFrame].size.height == 568.0){
			flag4inch  = YES;
		} else {
			flag4inch  = NO;
		}
		//--------------------------------------------
		
		glaphViewClass = [[GraphView alloc]init];

	}
	
	return self;
}

//------------------------------------------------------------------------------
// 生成
//------------------------------------------------------------------------------
- (void)showGraphAlert:(NSString *)title
			   message:(NSString *)message
				   tag:(int)tag
			replayData:(NSMutableArray *)replayData
         replayData1st:(NSMutableArray *)replayData1st
{
LOG();
	
	// スコア毎に再描画
	glaphView = [[GraphView alloc]initWithFrame:CGRectMake(0, 0, 280, 200)]; 
	glaphView.backgroundColor = RGBA(0.0, 7.0, 99.0, 1.0);
	glaphView.alpha = 0.7f;

	// 保存
	[[NSUserDefaults standardUserDefaults]setObject:replayData forKey:@"drawData"];
	[[NSUserDefaults standardUserDefaults]setObject:replayData1st forKey:@"drawData1st"];

	// alert初期化
	if(!alert){
		alert = [[UIAlertView alloc] initWithTitle: nil
										   message: nil
										  delegate: self
								 cancelButtonTitle: nil
								 otherButtonTitles: nil
				 ];
	}
	// 文言設定
	[alert setTitle:title];
	[alert setMessage:message];
	alert.tag = tag;
	
	// Repost Btn 追加
	if ( tag != 0 || [alert.title isEqualToString:@"Replay"] ) {
		// 通常
		[alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Replay", nil)]];
		[alert addButtonWithTitle:@"Cancel"];
	} else {
		// Repost
		[alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Replay", nil)]];
		[alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Repost best score", nil)]];
		[alert addButtonWithTitle:@"Cancel"];
	}
	
	
	[alert show];
	
}

//---------------------------------------------------------------
// カスタムアラート
//---------------------------------------------------------------
- (void)willPresentAlertView:(UIAlertView *)alertView {
LOG();
	
	//float center_X = alertView.center.x;
	float center_Y = alertView.center.y;
	
	// Label,button数
	NSInteger labelNum = 0;    
	NSInteger btnNum   = 0;
	
	// 位置関係
	if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
		// 通常alert
		alertView.frame = CGRectMake(0, 0, 330, ALERT_HEIGHT);
		alertView.center = CGPointMake(160, center_Y);
		
	} else {
		// Repost alert
		alertView.frame = CGRectMake(0, 0, 330, ALERT_HEIGHT_1ST);
		alertView.center = CGPointMake(160, center_Y);
	}
	
	// 広告位置
//  adView.frame  = CGRectMake(5, alertView.frame.size.height - 50,
//                 320, 50);
//  [alertView addSubview:adView];
//  
	// グラフ位置
	if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
		// 通常
		glaphView.center = CGPointMake(ALERT_CENTER_X,160 - 15);
	} else {
		// Repost
		glaphView.center = CGPointMake(ALERT_CENTER_X,160 - 20);
	}
	
	[alertView addSubview:glaphView];
	
	for (UIView* view in alertView.subviews) {
		
		// title & message
		if ([view isKindOfClass:NSClassFromString(@"UILabel")]) {
			
			// title & message size
			//view.frame = CGRectMake(0, 0, 370, 43);
			
			if (labelNum == 0){
				
				// title
				if(flag4inch){
					view.center = CGPointMake(ALERT_CENTER_X, center_Y-265);
				} else {
					view.center = CGPointMake(ALERT_CENTER_X, center_Y-220);
				}
				
			} else {
				// message
				if(flag4inch){
					if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
						// 通常
						view.center = CGPointMake(ALERT_CENTER_X, center_Y-5);
					} else {
						// Repost
						view.center = CGPointMake(ALERT_CENTER_X, center_Y-20);
					}
					
				} else {
					if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
						// 通常
						view.center = CGPointMake(ALERT_CENTER_X, center_Y+35);
					} else {
						// Repost
						view.center = CGPointMake(ALERT_CENTER_X, center_Y+25);
					}
				}
			}
			
			if ( btnNum < 3 ) {
				//increment
				labelNum++;
			}
		}
		
		// buttun
		if ([view isKindOfClass:NSClassFromString(@"UIAlertButton")]) {
			
			// button size
			if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
				// 通常
				view.frame = CGRectMake(0, 0, 130, 40);
			} else {
				// Repost
				view.frame = CGRectMake(0, 0, 295, 35);
			}

			// cancel button
			if (btnNum == 0) {
				// 2位以下のボタン配置
				if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
					// 通常
					view.center = CGPointMake(160-70+5, 330);
				} else {
					// Repost
					view.center = CGPointMake(ALERT_CENTER_X, 310);
					
				}
	
			} else {
				if ( alertView.tag != 0 || [alertView.title isEqualToString:@"Replay"] ) {
					// 通常
					view.center = CGPointMake(160+70+5, 330);
				} else {
					// Repost
					view.center = CGPointMake(ALERT_CENTER_X, 310 + (btnNum * 45) );
				}
				
			}
			//increment
			btnNum++;
		}
	}

}
//---------------------------------------------------------------
// ボタン押下時、delegateとselectorの指定があればownerへ通知
//---------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
LOG();
	// alertView.tag = 0は、Private
	// 2位以下はハンドラーに送るIndexを変える
	if ( alertView.tag != 0 && buttonIndex == 1 ) {
		buttonIndex = 2;
	}
	// オフライン時
	if ([alertView.title isEqualToString:@"Replay"] && buttonIndex == 1) {
		buttonIndex = 2;
	}
	
	if(delegate != nil && selector != nil ) {
		// 通知
		[self.delegate performSelector:selector withObject:[NSNumber numberWithInt:(int)buttonIndex]];
	}
	return;
}

//---------------------------------------------------------------
// UIAlertViewの解放
//---------------------------------------------------------------
- (void)releaseAlert {
LOG();
	
	if(alert != nil) {
		alert = nil;
	}

	// release
	[glaphViewClass releaseGraphView];
}


@end
