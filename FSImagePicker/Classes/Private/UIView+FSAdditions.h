//
//  UIView+FSAdditions.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FSAdditions)

- (void)fs_fillSuperview;
- (void)fs_fillSuperviewWithInsets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
