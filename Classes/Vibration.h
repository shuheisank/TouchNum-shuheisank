//
//  Vibration.h
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/22.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kVibratePeekFeedback 1519
#define kVibratePopFeedback 1520
#define kVibrateThreePulseFeedback 1521
#define kVibrateSystemVibrate 4095

NS_ASSUME_NONNULL_BEGIN

@interface Vibration : NSObject
+(Vibration*)sharedManager;
+(void)vibrateWeak;
+(void)vibrateShort;
+(void)vibrateLong;

@end

NS_ASSUME_NONNULL_END
