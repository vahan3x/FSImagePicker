//
//  FSImagePickerViewController.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import "FSImagePickerViewController.h"

#import "FSInternalPickerViewController.h"
#import "UIColor+FSAdditions.h"

@interface FSImagePickerViewController ()

@property (nonatomic) FSInternalPickerViewController *fs_rootViewController;
@property (nonatomic) UIStatusBarStyle fs_currentStatusBarStyle;

@end

@implementation FSImagePickerViewController

@dynamic delegate;

#pragma mark - Initialization

+ (instancetype)picker {
    return [[self alloc] init];
}

- (instancetype)init {
    FSInternalPickerViewController *picker = [[FSInternalPickerViewController alloc] init];
    if (self = [super initWithRootViewController:picker]) {
        self.fs_rootViewController = picker;
        self.mediaType = FSImagePickerMediaTypesPhoto;
        self.fs_currentStatusBarStyle = UIStatusBarStyleDefault;
        [self.navigationBar addObserver:self forKeyPath:@"barTintColor" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)dealloc {
    [self.navigationBar removeObserver:self forKeyPath:@"barTintColor"];
}

#pragma mark - Properties

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.fs_currentStatusBarStyle;
}

- (void)setDelegate:(id<FSImagePickerDelegate, UINavigationControllerDelegate>)delegate {
    self.fs_rootViewController.delegate = delegate;
    [super setDelegate:delegate];
}

- (void)setMediaType:(FSImagePickerMediaTypes)mediaType {
    self.fs_rootViewController.mediaType = mediaType;
}

- (FSImagePickerMediaTypes)mediaType {
    return self.fs_rootViewController.mediaType;
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.navigationBar] && [keyPath isEqualToString:@"barTintColor"]) {
        id newValue = change[NSKeyValueChangeNewKey];
        BOOL isLightBar;
        if ([newValue isEqual:[NSNull null]]) {
            isLightBar = self.navigationBar.barStyle == UIBarStyleDefault;
        } else {
            isLightBar = [newValue fs_isLightColor];
        }
        if (isLightBar && self.fs_currentStatusBarStyle == UIStatusBarStyleLightContent) {
            self.fs_currentStatusBarStyle = UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        } else if (!isLightBar && self.fs_currentStatusBarStyle == UIStatusBarStyleDefault) {
            self.fs_currentStatusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
