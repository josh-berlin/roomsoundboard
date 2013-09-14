#import "RSBSoundListViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "RSBCharacter.h"
#import "RSBSound.h"
#import "UIView+FLKAutoLayout.h"

@interface RSBSoundListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, copy) NSArray *sounds;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation RSBSoundListViewController

- (id)initWithCharacter:(RSBCharacter *)character {
  self = [super init];
  if (self) {
    self.title = character.name;
    _sounds = character.sounds;
    _tableView = [self newTableView];
    [self.view addSubview:_tableView];
    [self applyConstraints];
  }
  return self;
}

- (UITableView *)newTableView {
  UITableView *tableView = [[UITableView alloc] init];
  tableView.delegate = self;
  tableView.dataSource = self;
  tableView.backgroundColor = [UIColor clearColor];
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SoundCell"];
  return tableView;
}

- (void)applyConstraints {
  [self.tableView alignCenterWithView:self.view];
  [self.tableView constrainWidthToView:self.view predicate:nil];
  [self.tableView constrainHeightToView:self.view predicate:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Private

- (void)playSound:(NSString *)file {
  dispatch_queue_t audioQueue = dispatch_queue_create("com.theroom.audio", NULL);
  RSBSoundListViewController * __weak weakSelf = self;
  dispatch_async(audioQueue, ^{
    NSURL *fileURL = [NSURL fileURLWithPath:file];
    if (weakSelf.audioPlayer.isPlaying) {
      [weakSelf.audioPlayer stop];
    }
    weakSelf.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    [weakSelf.audioPlayer setVolume:1.0];
    [weakSelf.audioPlayer prepareToPlay];
    [weakSelf.audioPlayer play];
  });
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.sounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SoundCell"];
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.backgroundColor = [UIColor blackColor];
  RSBSound *sound = self.sounds[indexPath.row];
  cell.textLabel.text = sound.title;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  RSBSound *sound = self.sounds[indexPath.row];
  [self playSound:sound.soundPath];
}

@end
