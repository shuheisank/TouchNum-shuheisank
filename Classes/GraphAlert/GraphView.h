//
//  GraphView.h
//  TouchNumber
//
//  Created by Akihiko Sato on 2013/07/11.
//------------------------------------------------------------------------------
//	UPDATE	                Name				Comment
//
//  ver3.21     13/07/18    Akihiko Sato        Replay Graph 追加				　　　　　	
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface GraphView : UIView
{
	// RGB
	CGFloat            red,
	                 green,
	                 blue,
	                 alpha;
	
	int              k;
	UILabel          *labelLapTime[6];
	UILabel          *labelTime[6];
}

- (void)drawRect:(CGRect)rect;
- (void)initGraphParts;
- (void)drawInContext:(CGContextRef)context;
- (void)drawInContextTopScore:(CGContextRef)context;
- (void)releaseGraphView;
@end
