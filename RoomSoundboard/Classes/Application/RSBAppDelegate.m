#import "RSBAppDelegate.h"

#import "RSBViewController.h"

@interface RSBAppDelegate ()
@property(nonatomic, strong) UINavigationController *navigationController;
@property(nonatomic, strong) RSBViewController *roomViewController;
@end

@implementation RSBAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.roomViewController = [[RSBViewController alloc] init];
  self.navigationController =
      [[UINavigationController alloc] initWithRootViewController:self.roomViewController];
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
  
  [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
  
  return YES;
}

@end
