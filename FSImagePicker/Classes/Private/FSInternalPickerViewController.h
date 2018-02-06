//
//  FSInternalPickerViewController.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/2/18.
//

#import <UIKit/UIKit.h>

#import "FSImagePickerViewController.h"

@interface FSInternalPickerViewController : UIViewController

@property (nonatomic) FSImagePickerMediaTypes mediaType;
@property (nonatomic, nullable, weak) id<FSImagePickerDelegate> delegate;

- (void)updateVisibleItems;

@end
