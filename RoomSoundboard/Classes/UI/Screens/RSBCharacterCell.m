#import "RSBCharacterCell.h"

#import <QuartzCore/QuartzCore.h>

#import "RSBCharacter.h"

@implementation RSBCharacterCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _characterImageView = [self newCharacterImageView];
    [self.contentView addSubview:_characterImageView];
  }
  return self;
}

- (UIImageView *)newCharacterImageView {
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.layer.cornerRadius = 8.0f;
  imageView.layer.masksToBounds = YES;
  return imageView;
}

- (void)setCharacter:(RSBCharacter *)character {
  _character = character;
  self.characterImageView.image = [UIImage imageWithContentsOfFile:character.imagePath];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.characterImageView.frame = self.bounds;
}

@end
