//
//  FSImagePickerPreviewingViewController.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/3/18.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class PHImageManager;

NS_ASSUME_NONNULL_BEGIN

@interface FSImagePickerPreviewingViewController : UIViewController

@property (nonatomic, nullable, readonly) PHAsset *asset;
@property (nonatomic, null_resettable) PHImageManager *imageManager;

- (void)setAsset:(PHAsset *)asset withPreviewImage:(nullable UIImage *)previewImage;

@end

NS_ASSUME_NONNULL_END
