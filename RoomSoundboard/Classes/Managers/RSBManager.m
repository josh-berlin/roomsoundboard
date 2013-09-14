#import "RSBManager.h"

#import "AFHTTPRequestOperation.h"
#import "RSBCharacter.h"
#import "RSBSound.h"

@implementation RSBManager

- (void)removeAllFiles {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory
                                                                       error:nil];
  for (NSString *file in files) {
    [[NSFileManager defaultManager]
        removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file]
                   error:nil];
  }
}

- (void)loadCharacterDataWithCompletion:(void(^)(NSArray *))onComplete
                                failure:(void(^)(NSError *))onFailure {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"roomsounds" ofType:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfFile:path];
  NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:kNilOptions
                                                    error:nil];
  
  dispatch_queue_t queue = dispatch_queue_create("com.rsb.downloads", NULL);
  dispatch_async(queue, ^{
      NSMutableArray *characters = [NSMutableArray array];
      for (NSDictionary *characterDictionary in json) {
        RSBCharacter *character = [[RSBCharacter alloc] init];
        character.name = characterDictionary[@"person"];
        character.imageURL = characterDictionary[@"image"];
        [self downloadFileAtURL:character.imageURL completion:^(NSString *path) {
          character.imagePath = path;
        } failure:nil];
        NSMutableArray *sounds = [NSMutableArray array];
        for (NSDictionary *soundDictionary in characterDictionary[@"sounds"]) {
          RSBSound *sound = [[RSBSound alloc] init];
          sound.title = soundDictionary[@"title"];
          sound.soundURL = soundDictionary[@"sound"];
          [self downloadFileAtURL:sound.soundURL completion:^(NSString *path) {
            sound.soundPath = path;
          } failure:nil];
          [sounds addObject:sound];
        }
        character.sounds = sounds;
        [characters addObject:character];
      }
      onComplete(characters);
  });
}

- (void)downloadFileAtURL:(NSString *)urlString
               completion:(void(^)(NSString *))onComplete
                  failure:(void(^)(NSError *))onFailure {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *path =
      [documentsDirectory stringByAppendingPathComponent:[urlString lastPathComponent]];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    return;
  }
  
  NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"File downloaded: %@", path);
    if (onComplete) {
      onComplete(path);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"File download failed: %@", error);
    onFailure(error);
  }];
  [operation start];
  [operation waitUntilFinished];
}

@end
