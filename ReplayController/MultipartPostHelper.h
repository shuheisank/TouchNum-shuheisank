//
//  MultipartPostHelper.h
//  HTTPPostSample2
//
//  Created by mmlemon on 09/06/10.
//  Copyright 2009 hi-farm.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MultipartPostHelper : NSObject {
	
	NSString *url;	
	NSDictionary *stringValues;
	NSArray *binaryValues;	
	
@private
	NSString *boundary;	
}

@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSDictionary *stringValues;
@property(nonatomic, strong) NSArray *binaryValues;
@property(nonatomic, strong) NSString *boundary;

- (id)initWithURL:(NSString *)sendUrl;
- (void)sendWithDelegate:(id)delegate;
- (void)send:(NSString *)sendUrl delegate:(id)delegate;
- (void)sendDownloadRequest:(NSString *)name time:(double)time delegate:(id)delegate;

@end
