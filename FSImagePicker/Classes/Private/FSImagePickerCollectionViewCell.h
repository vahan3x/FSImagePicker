//
//  FSImagePickerCollectionViewCell.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FSImagePickerCollectionViewCellType) {
    FSImagePickerCollectionViewCellTypePhoto,
    FSImagePickerCollectionViewCellTypeVideo,
    FSImagePickerCollectionViewCellTypeLivePhoto,
};

NS_ASSUME_NONNULL_BEGIN

@interface FSImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, nullable) UIColor *selectionColor;
@property (nonatomic) FSImagePickerCollectionViewCellType type;

@property (nonatomic, nullable) UIImage *image;
@property (nonatomic) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
