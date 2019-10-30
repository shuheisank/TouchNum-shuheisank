//
//  ADFMediaView.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2018/06/22.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WKWebView;

@protocol ADFMediaViewDelegate <NSObject>
@optional
/**
 広告の再生開始
 */
- (void)onADFMediaViewPlayStart;

/**
 広告の再生完了
 */
- (void)onADFMediaViewPlayFinish;

/**
 広告の再生失敗
 */
- (void)onADFMediaViewPlayFail;

/**
 広告のClick
 */
- (void)onADFMediaViewClick;

- (void)onADFMediaViewLoadFinish;
- (void)onADFMediaViewLoadFail;

@end

@interface ADFMediaView : UIView
@property (nonatomic, nullable) id <ADFMediaViewDelegate> mediaViewDelegate;
@property (nonatomic, nullable) id <ADFMediaViewDelegate> adapterInnerDelegate;

- (void)setupWithView:(UIView *)view;
- (void)setupWithImage:(NSURL *)imageUrl movieUrl:(NSURL *)movieUrl;
- (void)setupWithHtml:(NSArray *)htmlData;
- (void)play;

- (NSDictionary *)getCurrentHtmlData;

@end
