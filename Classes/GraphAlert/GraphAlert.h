//
//  GraphAlert.h
//  TouchNumber
//
//  Created by Akihiko Sato on 2013/07/11.
//------------------------------------------------------------------------------
//	UPDATE	                Name				Comment
//
//  ver3.21     13/07/18    Akihiko Sato        Replay Graph 追加
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "Free.h"
#import "GraphView.h"


@interface GraphAlert : UIAlertView <UIAlertViewDelegate>
{
	GraphView     *glaphViewClass;
	UIView        *glaphView;
	BOOL          *flag4inch;
}

@property (nonatomic, weak) id	        delegate;
@property (nonatomic, assign) SEL	        selector;
@property (nonatomic, strong) UIAlertView   *alert;

- (id)	initWithDelegateAndSelector:(id)ownerDelegate selector:(SEL)ownerSelector;
- (void)showGraphAlert:(NSString *)title
			     message:(NSString *)message
				     tag:(int)tag
              replayData:(NSMutableArray *)replayData
           replayData1st:(NSMutableArray *)replayData1st;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)releaseAlert;

@end
