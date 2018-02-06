//
//  FSImagePickerViewController.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import <UIKit/UIKit.h>

@class FSImagePickerViewController;

NS_SWIFT_NAME(ImagePickerMediaTypes)
typedef NS_OPTIONS(NSUInteger, FSImagePickerMediaTypes) {
    FSImagePickerMediaTypesPhoto = 1 << 0,
    FSImagePickerMediaTypesVideo = 1 << 1,
    FSImagePickerMediaTypesLivePhoto = 1 << 2,
};

typedef NSString * FSImagePickerInfo NS_EXTENSIBLE_STRING_ENUM;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT FSImagePickerInfo const FSImagePickerInfoCancelled;
FOUNDATION_EXPORT FSImagePickerInfo const FSImagePickerInfoPickedItems;

NS_SWIFT_NAME(ImagePickerDelegate)
@protocol FSImagePickerDelegate <NSObject>

/**
 Tells the delegate that the user finished picking media.
 Your delegate’s implementation of this method should pass the specified image on to any custom code that needs it and then dismiss the picker view.

 @param picker The `FSImagePickerViewController` object of a delegate.
 @param info A dictionary containing any relevant user actions information. The keys for this dictionary are listed in **Media Picking Keys**.
 */
- (void)imagePicker:(FSImagePickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info;

@end

NS_SWIFT_NAME(ImagePickerViewController)
@interface FSImagePickerViewController : UINavigationController

/**
 The media types to display, default is `FSImagePickerMediaTypesPhoto`.
 */
@property (nonatomic) FSImagePickerMediaTypes mediaType;

/**
 Optional delegate to notify the picker's actions.
 */
@property (nonatomic, nullable, weak) id<FSImagePickerDelegate, UINavigationControllerDelegate> delegate;

/**
 A color to highlight the selected items.
 */
@property (nonatomic) UIColor *selectionColor;

/**
 Creates an `FSImagePickerViewController` instance with default values.

 @return Newly instanciated `FSImagePickerViewController` object.
 */
+ (instancetype)picker;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;
- (instancetype)initWithNavigationBarClass:(nullable Class)navigationBarClass toolbarClass:(nullable Class)toolbarClass NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
