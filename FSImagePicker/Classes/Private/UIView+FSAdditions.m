//
//  UIView+FSAdditions.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import "UIView+FSAdditions.h"

@implementation UIView (FSAdditions)

- (void)fs_fillSuperview {
    [self fs_fillSuperviewWithInsets:UIEdgeInsetsZero];
}

- (void)fs_fillSuperviewWithInsets:(UIEdgeInsets)insets {
    if (!self.superview) { return; }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:insets.top],
                                              [self.superview.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:insets.bottom],
                                              [self.leftAnchor constraintEqualToAnchor:self.superview.leftAnchor constant:insets.left],
                                              [self.superview.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:insets.right]
                                              ]];
}

@end
