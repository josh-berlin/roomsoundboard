#import "RSBCharacterCell.h"

#import <QuartzCore/QuartzCore.h>

#import "RSBCharacter.h"

@interface RSBCharacterCell ()
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation RSBCharacterCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _imageView = [self newImageView];
    [self.contentView addSubview:_imageView];
  }
  return self;
}

- (UIImageView *)newImageView {
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.layer.cornerRadius = 8.0f;
  imageView.layer.masksToBounds = YES;
  return imageView;
}

- (void)setCharacter:(RSBCharacter *)character {
  _character = character;
  self.imageView.image = [UIImage imageWithContentsOfFile:character.imagePath];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageView.frame = self.bounds;
}

@end
