//
//  FSImagePickerViewController.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/1/18.
//

#import "FSImagePickerViewController.h"

#import "FSInternalPickerViewController.h"

@interface FSImagePickerViewController ()

@property (nonatomic) FSInternalPickerViewController *fs_rootViewController;

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
    }
    
    return self;
}

#pragma mark - Properties

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

@end
