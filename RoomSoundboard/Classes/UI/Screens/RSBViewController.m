#import "RSBViewController.h"

#import "RSBCharacter.h"
#import "RSBCharacterCell.h"
#import "RSBManager.h"
#import "RSBSound.h"
#import "RSBSoundListViewController.h"

@interface RSBViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, copy) NSArray *characters;
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation RSBViewController

- (id)init {
  self = [super init];
  if (self) {
    self.title = @"the room";
    _collectionView = [self newCollectionView];
    [self.view addSubview:_collectionView];
  }
  return self;
}

- (UICollectionViewFlowLayout *)newCollectionViewFlowLayout {
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  flowLayout.itemSize = CGSizeMake(130, 130);
  flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
  flowLayout.minimumInteritemSpacing = 10.0f;
  flowLayout.minimumLineSpacing = 10.0f;
  return flowLayout;
}

- (UICollectionView *)newCollectionView {
  UICollectionViewFlowLayout *flowLayout = [self newCollectionViewFlowLayout];
  UICollectionView *collectionview = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                        collectionViewLayout:flowLayout];
  collectionview.dataSource = self;
  collectionview.delegate = self;
  [collectionview registerClass:[RSBCharacterCell class]
     forCellWithReuseIdentifier:@"CharacterCell"];
  return collectionview;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCharacters];
  self.collectionView.frame = self.view.bounds;
}

#pragma mark - Private

- (void)loadCharacters {
  RSBManager *manager = [[RSBManager alloc] init];
  [manager removeAllFiles]; // TODO(josh): Remove.
  RSBViewController * __weak weakSelf = self;
  [manager loadCharacterDataWithCompletion:^(NSArray *characters) {
    NSLog(@"Characters: %@", characters);
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.characters = characters;
        [weakSelf.collectionView reloadData];
    });
  } failure:^(NSError *error) {
    NSLog(@"Error: %@", error);
  }];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.characters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  RSBCharacterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CharacterCell"
                                                                     forIndexPath:indexPath];
  RSBCharacter *character = self.characters[indexPath.row];
  cell.character = character;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  RSBCharacter *character = self.characters[indexPath.row];
  RSBSoundListViewController *soundListViewController =
      [[RSBSoundListViewController alloc] initWithCharacter:character];
  [self.navigationController pushViewController:soundListViewController animated:YES];
}

@end
