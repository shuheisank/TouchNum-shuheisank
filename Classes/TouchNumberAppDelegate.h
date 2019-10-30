#import <UIKit/UIKit.h>
#import <Firebase.h>
#import <Adjust/Adjust.h>

#define ADJUST_APP_TOKEN @"o19gtfrmfwu8"

@class MainViewController;


//------------------------------------------------------------------------------
@interface TouchNumberAppDelegate : NSObject <UIApplicationDelegate>{

}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MainViewController *mainViewController;

@end

