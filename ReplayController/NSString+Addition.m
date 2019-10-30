//
//  NSString+MD5Addition.m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "NSString+Addition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(MD5Addition)


- (NSString*) sha1 {
    
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1( data.bytes, data.length, digest );
    
    NSMutableString* sha1 = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    //Write bytes to string in hexidecimal format
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [sha1 appendFormat:@"%02x", digest[i]];
    }
    
    return sha1;
    
}

- (NSString*) md5 {
    
    const char* cStr = [self UTF8String];
    NSData* data = [NSData dataWithBytes:cStr length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    
    //Calculate md5 digest
    CC_MD5( data.bytes, data.length, digest );
    
    NSMutableString* md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    //Write bytes to string in hexidecimal
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5 appendFormat:@"%02x", digest[i]];
    }
    
    return  md5;
    
}

- (NSData*) sha1Data {
    
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1( data.bytes, data.length, digest );
    
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
}

- (NSData*) md5Data {
    
    const char* cStr = [self UTF8String];
    NSData* data = [NSData dataWithBytes:cStr length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    
    //Calculate md5 digest
    CC_MD5( data.bytes, data.length, digest );
    
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    
}

@end
