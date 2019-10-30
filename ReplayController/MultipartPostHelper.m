//
//  MultipartPostHelper.m
//  HTTPPostSample2
//
//  Created by mmlemon on 09/06/10.
//  Copyright 2009 hi-farm.net. All rights reserved.
//

#import "MultipartPostHelper.h"

NSURLConnection *connection = nil;

@implementation MultipartPostHelper

@synthesize url;
@synthesize	stringValues;
@synthesize	binaryValues;
@synthesize	boundary;

- (id)init {
	if ([super init]) {
		[self setBoundary:@"AaB03x"];
	}
	return self;
}

- (id)initWithURL:(NSString *)sendUrl {
	if (!(self = [self init])) return nil;
	[self setUrl:sendUrl];
	return self;
}

- (void)dealloc {
    if (connection) {
        connection = nil;
    }
    self.boundary;
    self.binaryValues;
    self.stringValues;
    self.url;
}

- (NSData *)generatePostBinaryData:(NSData *)uploadData orgName:(NSString *)orgFileName postName:(NSString *)postLabel {
	NSMutableString *prePost = [[NSMutableString alloc] init];

	[prePost appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	[prePost appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", postLabel, orgFileName]];
	
	NSMutableData *returnValue = [[NSMutableData alloc] init];

	[returnValue appendData:[prePost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	[returnValue appendData:uploadData];
	
	[returnValue appendData:[[NSString stringWithFormat:@"\r\n--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding
				allowLossyConversion:YES]];
	
	return returnValue;
}


- (NSData *)generateMultiPartString:(NSString *)key kValue:(NSString *)value {
	NSMutableString *returnString = [[NSMutableString alloc] init];
	
	[returnString appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	[returnString appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]];
	[returnString appendString:value];
	[returnString appendString:@"\r\n"];
	
	NSData *returnValue = [[NSData alloc] initWithData:[returnString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	return returnValue;
}


- (void)sendWithDelegate:(id)delegate {
    NSAssert(self.url != nil, @"URL property is required");
	
	NSMutableData *postData = [[NSMutableData alloc] init];
	
	NSArray *stringValuesKeys = [self.stringValues allKeys];
	for (int i = 0; i < [stringValuesKeys count]; i++) {
		NSString *key = (NSString *)[stringValuesKeys objectAtIndex:i];		
		[postData appendData:[self generateMultiPartString:key kValue:[self.stringValues objectForKey:key]]];
	}
	
	for (int i = 0; i < [self.binaryValues count]; i++) {
		NSDictionary *binaryDict = (NSDictionary *)[self.binaryValues objectAtIndex:i];
		[postData appendData:[self generatePostBinaryData:(NSData *)[binaryDict objectForKey:@"data"]
												  orgName:(NSString *)[binaryDict objectForKey:@"orgName"]
												 postName:(NSString *)[binaryDict objectForKey:@"postName"]
		 ]];
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self url]] 
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	[request setHTTPMethod:@"POST"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
    if (connection) {
        connection = nil;
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
}

- (void)sendDownloadRequest:(NSString *)name time:(double)time delegate:(id)delegate {
    NSLog(@"%s", __func__);
    NSString *param = [NSString stringWithFormat:@"name=%@&time=%.5f", name, time];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];

    if (connection) {
        connection = nil;
    }
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
}

- (void)send:(NSString *)sendUrl delegate:(id)delegate {
	[self setUrl:sendUrl];
	[self sendWithDelegate:delegate];
}

@end
