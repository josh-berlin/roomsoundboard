#import "RSBAppDelegate.h"

#import "RSBCharacter.h"
#import "RSBSound.h"
#import "RSBViewController.h"

@implementation RSBAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"roomsounds" ofType:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfFile:path];
  NSArray *json =
      [NSJSONSerialization JSONObjectWithData:jsonData
                                      options:kNilOptions
                                        error:nil];
  
  NSMutableArray *characters = [NSMutableArray array];
  for (NSDictionary *characterDictionary in json) {
    RSBCharacter *character = [[RSBCharacter alloc] init];
    character.name = characterDictionary[@"person"];
    character.imageURL = characterDictionary[@"image"];
    NSMutableArray *sounds = [NSMutableArray array];
    for (NSDictionary *soundDictionary in characterDictionary[@"sounds"]) {
      RSBSound *sound = [[RSBSound alloc] init];
      sound.soundFile = soundDictionary[@"sound"];
      sound.title = soundDictionary[@"title"];
      [sounds addObject:sound];
    }
    character.sounds = sounds;
    [characters addObject:character];
  }
  
  UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  window.rootViewController = [[RSBViewController alloc] init];
  [window makeKeyAndVisible];
  
  return YES;
}

@end
