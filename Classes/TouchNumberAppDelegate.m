#import "TouchNumberAppDelegate.h"
#import "MainViewController.h"
#import "AdManager.h"

//------------------------------------------------------------------------------
@implementation TouchNumberAppDelegate

@synthesize window;
@synthesize mainViewController;


//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  LOG();
  
  [[AdManager sharedManager] initMovieNative];
  [[AdManager sharedManager] initMovieInterstitial];
  [[AdManager sharedManager] initMovieReward];

  [FIRApp configure];
  
  
  NSString *adjustAppToken = ADJUST_APP_TOKEN;
//  NSString *environment = ADJEnvironmentSandbox;
  NSString *environment = ADJEnvironmentProduction;
  ADJConfig *adjustConfig = [ADJConfig configWithAppToken:adjustAppToken
                                              environment:environment allowSuppressLogLevel:YES];
  [adjustConfig setLogLevel:ADJLogLevelVerbose];  // すべてのログを有効にする
  //  [adjustConfig setLogLevel:ADJLogLevelSuppress]; // すべてのログを無効にする
  [Adjust appDidLaunch:adjustConfig];

  
  
  
  [window addSubview:mainViewController.view];
  [window makeKeyAndVisible];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
  self.window.rootViewController  = self.mainViewController;
  [self.window makeKeyAndVisible];
  
  
  //プッシュ通知許可確認
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
  {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
  }
  else
  {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    
  }
    
  //プッシュ通知全部キャンセル
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  //バッジ0にする
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  
  return YES;
}


//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  LOG(@"%@", url);
  //LOG(@"%@", [url absoluteString]);
  
  return YES;
}
//------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
{
  NSLog(@"%s",__FUNCTION__);
  // twitter画面の処理
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"cancelPage" object:nil]];
  
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"enterBackGround" object:nil]];
}
//------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application{
  NSLog(@"%s",__FUNCTION__);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"becomeActive" object:nil]];
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  
  
  //最高タイム取得して、日付とタイムを使って条件分岐
  
  //3日後のお知らせ
  UILocalNotification *notification3 = [[UILocalNotification alloc] init];
  notification3.fireDate = [[NSDate date] dateByAddingTimeInterval: 60 * 60 * 24 * 3];
  //    notification3.fireDate = [[NSDate date] dateByAddingTimeInterval: 3];
  notification3.timeZone = [NSTimeZone defaultTimeZone];
  notification3.applicationIconBadgeNumber = 1;
  if ([self isLocaleJapanese]) {
    notification3.alertBody = @"１０秒で今日の調子がわかる";
    notification3.alertAction = @"開く";
  } else {
    notification3.alertBody = @"10 sec. brain workout.";
    notification3.alertAction = @"Open";
  }
  notification3.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] scheduleLocalNotification:notification3];
  
  //7日後のお知らせ
  UILocalNotification *notification7 = [[UILocalNotification alloc] init];
  notification7.fireDate = [[NSDate date] dateByAddingTimeInterval: 60 * 60 * 24 * 7];
  //    notification7.fireDate = [[NSDate date] dateByAddingTimeInterval: 7];
  notification7.timeZone = [NSTimeZone defaultTimeZone];
  notification7.applicationIconBadgeNumber = 2;
  if ([self isLocaleJapanese]) {
    notification7.alertBody = @"１０秒で脳を活性化";
    notification7.alertAction = @"開く";
  } else {
    notification7.alertBody = @"Reflesh your mind in 10 sec.";
    notification7.alertAction = @"Open";
  }
  notification7.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] scheduleLocalNotification:notification7];
  
  
  //14日後のお知らせ
  UILocalNotification *notification14 = [[UILocalNotification alloc] init];
  notification14.fireDate = [[NSDate date] dateByAddingTimeInterval: 60 * 60 * 24 * 14];
  //    notification14.fireDate = [[NSDate date] dateByAddingTimeInterval: 14];
  notification14.timeZone = [NSTimeZone defaultTimeZone];
  notification14.applicationIconBadgeNumber = 3;
  if ([self isLocaleJapanese]) {
    notification14.alertBody = @"１０秒で頭が良くなるかも";
    notification14.alertAction = @"開く";
  } else {
    notification14.alertBody = @"Become the genius with 10 sec training.";
    notification14.alertAction = @"Open";
  }
  notification14.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] scheduleLocalNotification:notification14];
  
  //30日後のお知らせ
  UILocalNotification *notification30 = [[UILocalNotification alloc] init];
  notification30.fireDate = [[NSDate date] dateByAddingTimeInterval: 60 * 60 * 24 * 30];
  //    notification30.fireDate = [[NSDate date] dateByAddingTimeInterval: 30];
  notification30.timeZone = [NSTimeZone defaultTimeZone];
  notification30.applicationIconBadgeNumber = 4;
  if ([self isLocaleJapanese]) {
    notification30.alertBody = @"１～２５までの数字早押しで簡単脳トレ";
    notification30.alertAction = @"開く";
  } else {
    notification30.alertBody = @"I missed you. Let's train your brain again.";
    notification30.alertAction = @"Open";
  }
  notification30.soundName = UILocalNotificationDefaultSoundName;
  [[UIApplication sharedApplication] scheduleLocalNotification:notification30];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  
}


//------------------------------------------------------------------------------

//ローカルノーティフィケーション受信時
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
  
  //3日以上起動していない場合にしか受信しないため、通ることはない
}

//日本語判別
-(BOOL)isLocaleJapanese{
  NSArray *languages = [NSLocale preferredLanguages];
  NSString *languageID = [languages objectAtIndex:0];
  if ([languageID isEqualToString:@"ja"]) return YES;
  return NO;
}

//------------------------------------------------------------------------------
- (void)dealloc {
  LOG();
}

@end

