//
//  ADFLogger.h
//  ADFMovieReward
//
//  Created by Amin Al on 2018/06/26.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADFLogLevel) {
    ADFLogLevelVerbose = 0,
    ADFLogLevelTrace = 1,
    ADFLogLevelDebug = 2,
    ADFLogLevelInfo = 3,
    ADFLogLevelWarning = 4,
    ADFLogLevelError = 5,
    ADFLogLevelSevere = 6,
    ADFLogLevelNone = 7
};

@interface ADFLogger : NSObject

@property (class, atomic) ADFLogLevel logLevel;

+ (void)setLogLevel: (ADFLogLevel)level;
+ (void)debug: (NSString *)format, ...;
+ (void)info: (NSString *)format, ...;
+ (void)trace;
+ (void)warning: (NSString *)format, ...;
+ (void)error: (NSString *)format, ...;
+ (void)severe: (NSString *)format, ...;
+ (NSString *)getLogLevelName:(ADFLogLevel)level;

@end
