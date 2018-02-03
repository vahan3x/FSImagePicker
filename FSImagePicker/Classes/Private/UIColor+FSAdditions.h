//
//  UIColor+FSAdditions.h
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/3/18.
//

#import <UIKit/UIKit.h>

@interface UIColor (FSAdditions)

@property (nonatomic, readonly, getter=fs_isLightColor) BOOL fs_lightColor;

@end
