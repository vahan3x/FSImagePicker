//
//  FSImagePickerCollectionViewCell.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import "FSImagePickerCollectionViewCell.h"

#import "UIView+FSAdditions.h"

static NSString *const FSLivePhotoIndicatorIconName = @"LivePhoto";
static NSString *const FSTSelectionIconName = @"Selection";
static NSString *const FSThumbnailIconName = @"Thumbnail";

@interface FSImagePickerCollectionViewCell ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIImageView *livePhotoIndicatorImageView;
@property (nonatomic, weak) UILabel *videoDurationLabel;

@end

@implementation FSImagePickerCollectionViewCell

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    [imageView fillSuperview];
    self.imageView = imageView;
    UIImage *live = [UIImage imageNamed:FSLivePhotoIndicatorIconName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    UIImageView *livePhotoIndicatorImageView = [[UIImageView alloc] initWithImage:live];
    livePhotoIndicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:livePhotoIndicatorImageView];
    self.livePhotoIndicatorImageView = livePhotoIndicatorImageView;
    
    UILabel *videoDurationLabel = [[UILabel alloc] init];
    videoDurationLabel.numberOfLines = 1;
    videoDurationLabel.font = [UIFont systemFontOfSize:11.0];
    videoDurationLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    videoDurationLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:videoDurationLabel];
    self.videoDurationLabel = videoDurationLabel;
    
    livePhotoIndicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    videoDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.contentView.rightAnchor constraintEqualToAnchor:livePhotoIndicatorImageView.rightAnchor
                                                                                           constant:8.0],
                                              [self.contentView.bottomAnchor constraintEqualToAnchor:livePhotoIndicatorImageView.bottomAnchor
                                                                                            constant:8.0],
                                              [livePhotoIndicatorImageView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor
                                                                                                     multiplier:0.1],
                                              [livePhotoIndicatorImageView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor
                                                                                                    multiplier:0.1],
                                              
                                              [self.contentView.rightAnchor constraintEqualToAnchor:videoDurationLabel.rightAnchor
                                                                                           constant:8.0],
                                              [self.contentView.bottomAnchor constraintEqualToAnchor:videoDurationLabel.bottomAnchor
                                                                                            constant:8.0],
                                              [NSLayoutConstraint constraintWithItem:videoDurationLabel attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                              toItem:self.contentView attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0 constant:0.0]
                                              ]];
    
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor blueColor];
    
    return self;
}

#pragma mark - Lifecycle

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.image = [UIImage imageNamed:FSThumbnailIconName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    self.duration = 0.0;
}

#pragma mark - Properties

- (void)setSelected:(BOOL)selected {
    if (selected && !self.selected) {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0
                            options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                                self.contentView.transform = CGAffineTransformScale(self.contentView.transform, 0.95, 0.95);
                            } completion:nil];
    } else if (!selected && [self isSelected]) {
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0
                            options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                                self.contentView.transform = CGAffineTransformIdentity;
                            } completion:nil];
    }
    
    [super setSelected:selected];
}

- (void)setSelectionColor:(UIColor *)selectionColor {
    self.selectedBackgroundView.backgroundColor = selectionColor;
}

- (UIColor *)selectionColor {
    return self.selectedBackgroundView.backgroundColor;
}

- (void)setType:(FSImagePickerCollectionViewCellType)type {
    _type = type;
    switch (type) {
        case FSImagePickerCollectionViewCellTypePhoto:
            self.livePhotoIndicatorImageView.hidden = self.videoDurationLabel.hidden = YES;
            break;
        case FSImagePickerCollectionViewCellTypeVideo:
            self.livePhotoIndicatorImageView.hidden = YES;
            self.videoDurationLabel.hidden = NO;
            break;
        case FSImagePickerCollectionViewCellTypeLivePhoto:
            self.livePhotoIndicatorImageView.hidden = NO;
            self.videoDurationLabel.hidden = YES;
            break;
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    int minutes = duration / 60;
    self.videoDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, (int)(duration - minutes * 60)];
}

@end
