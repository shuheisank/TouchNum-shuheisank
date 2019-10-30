//
//  NSString+MD5Addition.h
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Addition)

- (NSString*) sha1;
- (NSString*) md5;

- (NSData*) sha1Data;
- (NSData*) md5Data;

@end
