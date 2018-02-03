//
//  FSViewController.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 02/01/2018.
//  Copyright (c) 2018 vahan3x. All rights reserved.
//

#import "FSViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@import FSImagePicker;

@interface FSViewController () <FSImagePickerDelegate, UINavigationControllerDelegate>

@end

@implementation FSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    FSImagePickerViewController *picker = [FSImagePickerViewController picker];
    picker.mediaType = FSImagePickerMediaTypesVideo | FSImagePickerMediaTypesPhoto | FSImagePickerMediaTypesLivePhoto;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - FSImagePickerDelegate

- (void)imagePicker:(FSImagePickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@", info);
}

@end
