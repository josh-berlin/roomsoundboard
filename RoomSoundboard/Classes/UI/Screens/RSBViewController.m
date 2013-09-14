#import "RSBViewController.h"

#import "MBProgressHUD.h"
#import "RSBCharacter.h"
#import "RSBCharacterCell.h"
#import "RSBManager.h"
#import "RSBSound.h"
#import "RSBSoundListViewController.h"
#import "UIView+FLKAutoLayout.h"

@interface RSBViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, copy) NSArray *characters;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) RSBSoundListViewController *soundListViewController;
@property(nonatomic, strong) NSIndexPath *displayedCharacterCellIndexPath;
@end

@implementation RSBViewController

- (id)init {
  self = [super init];
  if (self) {
    self.title = @"the room";
    _collectionView = [self newCollectionView];
    [self.view addSubview:_collectionView];
    [self applyConstraints];
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

- (UIBarButtonItem *)newDoneBarButtonItem {
  return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self
                                                       action:@selector(closeSoundsList)];
}

- (void)applyConstraints {
  [self.collectionView constrainHeightToView:self.view predicate:nil];
  [self.collectionView constrainWidthToView:self.view predicate:nil];
  [self.collectionView alignCenterWithView:self.view];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCharacters];
}

#pragma mark - Private

- (void)loadCharacters {
  [MBProgressHUD showHUDAddedTo:self.collectionView animated:NO];
  RSBManager *manager = [[RSBManager alloc] init];
  [manager removeAllFiles]; // TODO(josh): Remove.
  RSBViewController * __weak weakSelf = self;
  [manager loadCharacterDataWithCompletion:^(NSArray *characters) {
    NSLog(@"Characters: %@", characters);
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.characters = characters;
        [weakSelf.collectionView reloadData];
        [MBProgressHUD hideAllHUDsForView:weakSelf.collectionView animated:NO];
    });
  } failure:^(NSError *error) {
      [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
      NSLog(@"Error: %@", error);
  }];
}

- (void)closeSoundsList {
  [self.soundListViewController willMoveToParentViewController:nil];
  [self.soundListViewController.view removeFromSuperview];
  [self moveTopCharacterCellToCollectionView];
  [self.soundListViewController didMoveToParentViewController:nil];
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)moveCharacterCellToTopAtIndexPath:(NSIndexPath *)indexPath {
  self.displayedCharacterCellIndexPath = indexPath;
  RSBCharacterCell *cell =
      (RSBCharacterCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  UIImageView *imageView = cell.characterImageView;
  CGPoint center = [self.view convertPoint:imageView.center fromView:imageView];
  imageView.center = center;
  [imageView removeFromSuperview];
  [self.view addSubview:imageView];
  [UIView animateWithDuration:0.25f
                   animations:^{
                       imageView.center = CGPointMake(self.view.center.x, imageView.bounds.size.height/2.0f);
                       [self.soundListViewController.view
                            constrainWidthToView:self.view predicate:nil];
                       [self.soundListViewController.view
                            alignBottomEdgeWithView:self.view predicate:nil];
                       [self.soundListViewController.view
                            constrainTopSpaceToView:cell.characterImageView predicate:nil];
                       for (RSBCharacterCell *cell in [self.collectionView visibleCells]) {
                         if (cell.characterImageView != imageView) {
                           cell.alpha = 0.0f;
                         }
                       }
                   }];
}

- (void)moveTopCharacterCellToCollectionView {
  RSBCharacterCell *cell =
      (RSBCharacterCell *)[self.collectionView
                           cellForItemAtIndexPath:self.displayedCharacterCellIndexPath];
  CGPoint center = [self.view convertPoint:cell.contentView.center fromView:cell.contentView];
  [UIView animateWithDuration:0.25f
                   animations:^{
                       cell.characterImageView.center = center;
                       for (RSBCharacterCell *cell in [self.collectionView visibleCells]) {
                          cell.alpha = 1.0f;
                       }
                   }
                   completion:^(BOOL finished) {
                     [cell.characterImageView removeFromSuperview];
                     [cell.contentView addSubview:cell.characterImageView];
                     cell.characterImageView.center = cell.contentView.center;
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
  self.soundListViewController = [[RSBSoundListViewController alloc] initWithCharacter:character];
  [self addChildViewController:self.soundListViewController];
  
  [self beginAppearanceTransition:YES animated:YES];

  [self.view addSubview:self.soundListViewController.view];
  [self moveCharacterCellToTopAtIndexPath:indexPath];
  [self endAppearanceTransition];
  
  [self.soundListViewController didMoveToParentViewController:self];
  [self.navigationItem setRightBarButtonItem:[self newDoneBarButtonItem] animated:YES];
}

@end
