#import "RSBSoundListViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "RSBCharacter.h"
#import "RSBSound.h"

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

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  self.tableView.frame = self.view.bounds;
}

#pragma mark - Private

- (void)playSound:(NSString *)file {
  NSURL *fileURL = [NSURL fileURLWithPath:file];
  if (self.audioPlayer.isPlaying) {
    [self.audioPlayer stop];
  }
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
  [self.audioPlayer setVolume:1.0];
  [self.audioPlayer prepareToPlay];
  [self.audioPlayer play];
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
