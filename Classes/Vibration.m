//
//  Vibration.m
//  TouchNum
//
//  Created by tekunodo. Kamata Air on 2019/08/22.
//

#import "Vibration.h"
static Vibration *sharedManager;

@implementation Vibration

#pragma mark - Singleton

+(Vibration*)sharedManager{
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

+(id)allocWithZone:(struct _NSZone *)zone{
  
  __block id ret = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedManager = [super allocWithZone:zone];
    ret = sharedManager;
  });
  return ret;
}

#pragma mark -

+(void)vibrateWeak{
  AudioServicesPlayAlertSoundWithCompletion(kVibratePeekFeedback, nil);
}
+(void)vibrateShort{
  AudioServicesPlayAlertSoundWithCompletion(kVibratePopFeedback, nil);
}
+(void)vibrateLong{
  AudioServicesPlayAlertSoundWithCompletion(kVibrateSystemVibrate, nil);
}


@end
