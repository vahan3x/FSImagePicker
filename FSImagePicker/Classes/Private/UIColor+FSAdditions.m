//
//  UIColor+FSAdditions.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/3/18.
//

#import "UIColor+FSAdditions.h"

@implementation UIColor (FSAdditions)

- (BOOL)fs_isLightColor {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return (red * 299.0 + green * 587.0 + blue * 114.0) / 1000.0 >= 0.5;
}

@end
