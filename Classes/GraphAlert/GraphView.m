//
//  GraphView.m
//  TouchNumber
//
//  Created by Akihiko Sato on 2013/07/11.
//------------------------------------------------------------------------------
//	UPDATE	                Name				Comment
//
//  ver3.21     13/07/18    Akihiko Sato        Replay Graph 追加
//------------------------------------------------------------------------------

#import "GraphView.h"

@implementation GraphView

- (id)initWithFrame:(CGRect)frame
{
LOG();
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		}
    return self;
}

- (void)drawRect:(CGRect)rect
{
LOG();
	// init
	[self initGraphParts];
	
	// Replay Data Graph
	[self drawInContext:UIGraphicsGetCurrentContext()];
	
	// 1st Score Graph
	[self drawInContextTopScore:UIGraphicsGetCurrentContext()];	
}

- (void)initGraphParts {
LOG();
	
	// Y軸 ラップタイム表示
	for (k = 1; k < 7; k++) {
		
		if(!labelLapTime[k]) {
			
			labelLapTime[k] = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
			labelLapTime[k].center = CGPointMake(5, 189-(37*(k-1)));
			labelLapTime[k].backgroundColor = [UIColor clearColor];
			labelLapTime[k].textColor       = [UIColor whiteColor];
			labelLapTime[k].font = [UIFont systemFontOfSize:8];
			if(k == 1){
				labelLapTime[k].text = @"0";
			} else {
				labelLapTime[k].text = [NSString stringWithFormat:@"%.2f",(k-1)*0.25];
			}
      labelLapTime[k].textAlignment = NSTextAlignmentCenter;
			[self addSubview:labelLapTime[k]];
		}
	}
	
	// X軸 回数表示
	for (int i = 1; i < 6; i++) {
		
		if (!labelTime[i]) {
			
			labelTime[i] = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
			labelTime[i].center = CGPointMake(10.0 + 11.04*(i*5), 195);
			labelTime[i].textAlignment = NSTextAlignmentCenter;
			if (i == 5){ // 例外
				labelTime[i].textAlignment = NSTextAlignmentLeft;
			}
			labelTime[i].backgroundColor = [UIColor clearColor];
			labelTime[i].textColor       = [UIColor whiteColor];
			labelTime[i].font = [UIFont systemFontOfSize:9];
			labelTime[i].text = [NSString stringWithFormat:@"%d",i*5];
			[self addSubview:labelTime[i]];
		}
	}
}

-(void)drawInContext:(CGContextRef)context
{
LOG();

	// X,Y軸を描画
	[RGBA(0.0, 0.0, 255.0, 0.5) getRed:&red green:&green blue:&blue alpha:&alpha];
	CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
	CGPoint axis[] =
	{
		CGPointMake(275, 5.0),
		CGPointMake(10.0, 5.0),   // 起点
		CGPointMake(10.0, 190.0),  // Y軸
		CGPointMake(275.0,190.0),  // X軸
	};
	CGContextAddLines(context, axis, 4);
	CGContextStrokePath(context);
	
	// Y軸
	for(int i = 1; i < 13; i++) {
		CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		CGPoint axis_Y[] =
		{
			CGPointMake(10.0 + 22.08 * i, 5.0),
			CGPointMake(10.0 + 22.08 * i, 190.0),
		};
		CGContextAddLines(context, axis_Y, 2);
		CGContextStrokePath(context);
	}
	
	// X軸
	for(int i = 1; i < 5; i++) {
		CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		CGPoint axis_X[] =
		{
			CGPointMake(10.0, 190.0 - 37 * i),
			CGPointMake(275.0,190.0 - 37 * i),
		};
		CGContextAddLines(context, axis_X, 2);
		CGContextStrokePath(context);
	}
	//---------------------------------------------------------
	// グラフの描画
	//---------------------------------------------------------
	NSMutableArray *timeArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"drawData"];
	
	//---------------------------------------------------------
	// laptime
	NSMutableArray *laptimeArray = [NSMutableArray array];
	
	double lapTime[26];
	
	for(int i = 1; i<25; i++){
		lapTime[i] = [[timeArray objectAtIndex:i+1]doubleValue] - [[timeArray objectAtIndex:i]doubleValue];
		[laptimeArray addObject:[NSNumber numberWithDouble:lapTime[i]]];
	}
	
	//---------------------------------------------------------
	// laptime compare
	double failTime = [[NSNumber numberWithDouble:lapTime[0]]doubleValue];
	
	for (int i = 1; i < 26; i++) {
		NSComparisonResult result = [[NSNumber numberWithDouble:failTime] compare:[NSNumber numberWithDouble:lapTime[i]]];
		switch (result) {
			case NSOrderedAscending:
				// failTime < lapTime
				failTime = [[NSNumber numberWithDouble:lapTime[i]]doubleValue];
				break;
				
			default:
				break;
		}
	}
	
    //---------------------------------------------------------
	// 小数第二位を調べて、0.05sec幅で数値調節
	double max_Y;
	
	if ( [[[NSString stringWithFormat:@"%.3f",failTime]substringWithRange:NSMakeRange(3, 1)]intValue] >= 5 ) {
		// 小数第一位を繰り上げ
		max_Y = [[NSString stringWithFormat:@"%.1f",failTime]doubleValue];
	} else {
		max_Y = [[NSString stringWithFormat:@"%.1f",failTime]doubleValue] + 0.05 ;
	}
	
	/*
	LOG(@"***** failTime:%f",failTime);
	LOG(@"***** 小数第二位:%d",[[[NSString stringWithFormat:@"%.3f",failTime]substringWithRange:NSMakeRange(3, 1)]intValue]);
	LOG(@"***** max_Y:%.3f",max_Y);
	*/ 
	
	[labelLapTime[2] setText:[NSString stringWithFormat:@"%.2f",max_Y*1/5]];
	[labelLapTime[3] setText:[NSString stringWithFormat:@"%.2f",max_Y*2/5]];
	[labelLapTime[4] setText:[NSString stringWithFormat:@"%.2f",max_Y*3/5]];
	[labelLapTime[5] setText:[NSString stringWithFormat:@"%.2f",max_Y*4/5]];
	[labelLapTime[6] setText:[NSString stringWithFormat:@"%.2f",max_Y]];

	//---------------------------------------------------------
	// 描画Y座標取得
	
	//double graphCenter = [labelLapTime[5].text doubleValue];
	double relativityPoint_Y[25];
	
	relativityPoint_Y[0] = 190.0;
	
	NSMutableArray *arrPointY = [NSMutableArray array];
	[arrPointY addObject:[NSNumber numberWithDouble:relativityPoint_Y[0]]];
	
	for(int p = 1; p < 25; p++){
		
		relativityPoint_Y[p] = 190 - ( ( [[laptimeArray objectAtIndex:p-1]doubleValue] / max_Y ) * 185 );
		[arrPointY addObject:[NSNumber numberWithDouble:relativityPoint_Y[p]]];
		if(relativityPoint_Y[p] < 5.0){
			// グラフからはみ出ないように処理
			relativityPoint_Y[p] = 5.0;
		}
	}

	// 保存
	[[NSUserDefaults standardUserDefaults]setObject:arrPointY forKey:@"PointY"];
	
	// 描画は最後に行う
	
}

// 1st Score Graph
-(void)drawInContextTopScore:(CGContextRef)context {
LOG();
	// グラフの描画
	NSMutableArray *timeArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"drawData1st"];

	//---------------------------------------------------------
	// laptime
	NSMutableArray *laptimeArray = [NSMutableArray array];
	
	double lapTime[26];
	
	for(int i = 1; i<25; i++){
		lapTime[i] = [[timeArray objectAtIndex:i+1]doubleValue] - [[timeArray objectAtIndex:i]doubleValue];
		
		[laptimeArray addObject:[NSNumber numberWithDouble:lapTime[i]]];
	}

	//---------------------------------------------------------
	// 描画Y座標取得
	double graphMax = [labelLapTime[6].text doubleValue];
	double relativityPoint_Y[25];
	
	relativityPoint_Y[0] = 190.0;
	
	for(int p = 1; p < 25; p++) {
		
		relativityPoint_Y[p] = 190 - ( ( [[laptimeArray objectAtIndex:p-1]doubleValue] / graphMax ) * 185 );
		if(relativityPoint_Y[p] < 5.0){
			// グラフからはみ出ないように処理
			relativityPoint_Y[p] = 5.0;
		}
	}
	//---------------------------------------------------------
	// Draw 1st Score
	[RGBA(125.0, 125.0, 125.0, 1.0) getRed:&red green:&green blue:&blue alpha:&alpha];
	for(int i = 0; i < 24; i++) {
		CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		CGPoint topScorelines[] =
		{
			CGPointMake(10.0 + 11.04 * i,  relativityPoint_Y[i]),
			CGPointMake(10.0 + 11.04 * (i+1),  relativityPoint_Y[(i+1)]),
		};
		CGContextAddLines(context, topScorelines, 2);
		CGContextStrokePath(context);
	}
	
	// 点を描画
	[RGBA(125.0, 125.0, 125.0, 1.0) getRed:&red green:&green blue:&blue alpha:&alpha];
	for(int i = 1; i < 25; i++) {
		// 1.3は中心調整の誤差
		CGContextSetRGBFillColor(context, red, green, blue, alpha);
		if (i < 25) {
			CGContextFillEllipseInRect(context,
			CGRectMake((10.0 + 11.04 * i)-1.3, relativityPoint_Y[i]-1.3, 3, 3));
		} else {
			CGContextFillEllipseInRect(context,
			CGRectMake((10.0 + 11.04 * i)-1.3, 290-1.3, 3, 3));
		}
	}
	
	//---------------------------------------------------------
	// Draw Replay Graph
	NSMutableArray *arr = [[NSUserDefaults standardUserDefaults]objectForKey:@"PointY"];
	
	// Back Graph Line Draw
	[RGBA(0.0, 255.0, 255.0, 0.3) getRed:&red green:&green blue:&blue alpha:&alpha];
	for(int i = 0; i < 24; i++) {
		CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		CGPoint nowScorelines[] =
		{
			CGPointMake(10.0 + 11.04 * i,    [[arr objectAtIndex:i]doubleValue]),
			CGPointMake(10.0 + 11.04 * (i+1),[[arr objectAtIndex:i+1]doubleValue]),
		};
		CGContextSetLineWidth(context, 2.5);
		CGContextAddLines(context, nowScorelines, 2);
		CGContextStrokePath(context);
	}
	
	[RGBA(0.0, 255.0, 255.0, 1.0) getRed:&red green:&green blue:&blue alpha:&alpha];
	 for(int i = 0; i < 24; i++) {
		 CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		 CGPoint nowScorelines[] =
		 {
			 CGPointMake(10.0 + 11.04 * i,    [[arr objectAtIndex:i]doubleValue]),
			 CGPointMake(10.0 + 11.04 * (i+1),[[arr objectAtIndex:i+1]doubleValue]),
		 };
		 CGContextSetLineWidth(context, 1.0);
		 CGContextAddLines(context, nowScorelines, 2);
		 CGContextStrokePath(context);
	 }
	
	// 点を描画
	[RGBA(100.0, 255.0, 255.0, 1.0) getRed:&red green:&green blue:&blue alpha:&alpha];
	for(int i = 1; i < 25; i++) {
		// 1.3は中心調整の誤差
		CGContextSetRGBFillColor(context, red, green, blue, alpha);
		if (i < 25) {
			CGContextFillEllipseInRect(context,
			CGRectMake((10.0 + 11.04 * i)-1.3, ([[arr objectAtIndex:i]doubleValue])-1.3, 3, 3));
		} else {
			CGContextFillEllipseInRect(context,
			CGRectMake((10.0 + 11.04 * i)-1.3, 290-1.3, 3, 3));
		}
	}

	//---------------------------------------------------------
	// 1st Label
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	if ( 190 < relativityPoint_Y[24]+10 ) {
		label.center = CGPointMake(275, 180);
	} else {
		label.center = CGPointMake(275, relativityPoint_Y[24]+10);
	}
	label.backgroundColor = [UIColor clearColor];
	label.textColor       = [UIColor whiteColor];
	label.alpha = 0.8;
	label.font = [UIFont systemFontOfSize:9];
	label.text = @"Best";
	label.textAlignment = NSTextAlignmentLeft;
	[self addSubview:label];
	
	//---------------------------------------------------------
	// remove
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"drawData"];
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"drawData1st"];
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"PointY"];

}

// release
- (void)releaseGraphView {
LOG();
	for (int i = 1; i < 7; i++) {
		if( labelLapTime[i] != nil ) {
			labelLapTime[i] = nil;
		}
	}
	
	for (int i = 1; i < 6; i++) {
		if ( labelTime[i] != nil ) {
			labelTime[i] = nil;
		}
	}	
}

@end
