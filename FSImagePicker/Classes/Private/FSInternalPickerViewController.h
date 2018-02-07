//
//  FSInternalPickerViewController.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/2/18.
//

#import <UIKit/UIKit.h>

#import "FSImagePickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSInternalPickerViewController : UIViewController

@property (nonatomic) FSImagePickerMediaTypes mediaType;
@property (nonatomic, nullable, weak) id<FSImagePickerDelegate> delegate;
@property (nonatomic, nullable) UIColor *backgroundColor;

- (void)updateVisibleItems;

@end

NS_ASSUME_NONNULL_END
