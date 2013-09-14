@interface RSBManager : NSObject

- (void)removeAllFiles;

- (void)loadCharacterDataWithCompletion:(void(^)(NSArray *))onComplete
                                failure:(void(^)(NSError *))onFailure;

- (void)downloadFileAtURL:(NSString *)urlString
               completion:(void(^)(NSString *))onComplete
                  failure:(void(^)(NSError *))onFailure;

@end
