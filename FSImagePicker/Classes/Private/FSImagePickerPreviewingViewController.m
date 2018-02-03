//
//  FSImagePickerPreviewingViewController.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/3/18.
//

#import "FSImagePickerPreviewingViewController.h"

#import "UIView+FSAdditions.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <AVFoundation/AVFoundation.h>

@interface FSImagePickerPreviewingViewController ()

@property (nonatomic) PHAsset *asset;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) PHLivePhotoView *livePhotoView;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;

@property (nonatomic) UIImage *previewImage;
@property (nonatomic) UIImage *image;
@property (nonatomic) PHLivePhoto *livePhoto;
@property (nonatomic) AVPlayer *player;
@property (nonatomic, getter=isViewAppeared) BOOL viewAppeared;

@end

@implementation FSImagePickerPreviewingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image ?: self.previewImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView fs_fillSuperview];
    self.imageView = imageView;
    
    PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] init];
    livePhotoView.livePhoto = self.livePhoto;
    [self.view addSubview:livePhotoView];
    [livePhotoView fs_fillSuperview];
    self.livePhotoView = livePhotoView;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.backgroundColor = nil;
    [self.view.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
    
    self.view.backgroundColor = imageView.backgroundColor = livePhotoView.backgroundColor = nil;
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewAppeared = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.viewAppeared = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.playerLayer.frame = self.view.layer.bounds;
}

- (void)setAsset:(PHAsset *)asset withPreviewImage:(UIImage *)previewImage {
    self.previewImage = previewImage;
    self.asset = asset;
    [self updateAppearance];
}

- (void)updateAppearance {
    if (self.livePhoto) {
        self.livePhotoView.livePhoto = self.livePhoto;
        self.livePhotoView.hidden = NO;
        self.imageView.hidden = self.playerLayer.hidden = YES;
        [self.player pause];
        if ([self isViewAppeared]) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    } else if (self.player) {
        self.playerLayer.player = self.player;
        self.playerLayer.hidden = NO;
        self.imageView.hidden = self.livePhotoView.hidden = YES;
        [self.livePhotoView stopPlayback];
        if ([self isViewAppeared]) {
            [self.player play];
        }
    } else {
        self.imageView.image = self.image ?: self.previewImage;
        self.imageView.hidden = NO;
        self.livePhotoView.hidden = self.playerLayer.hidden = YES;
        [self.player pause];
        [self.livePhotoView stopPlayback];
    }
}

#pragma mark - Properties

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    self.player = nil;
    self.livePhoto = nil;
    self.image = nil;
    
    __weak typeof(self) welf = self;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *requestOptions = [[PHVideoRequestOptions alloc] init];
        requestOptions.networkAccessAllowed = YES;
        requestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [self.imageManager requestPlayerItemForVideo:asset options:requestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (!playerItem) { return; }
            welf.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf updateAppearance];
                if ([welf isViewAppeared]) {
                    [welf.player play];
                }
            });
        }];
    } else if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        PHLivePhotoRequestOptions *requestOptions = [[PHLivePhotoRequestOptions alloc] init];
        requestOptions.networkAccessAllowed = YES;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [self.imageManager requestLivePhotoForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (!livePhoto) { return; }
            welf.livePhoto = livePhoto;
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf updateAppearance];
                if ([self isViewAppeared]) {
                    [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
                }
            });
        }];
    } else {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.networkAccessAllowed = YES;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [self.imageManager requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (!result) { return; }
            welf.image = result;
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf updateAppearance];
            });
        }];
    }
}

- (PHImageManager *)imageManager {
    if (_imageManager) {
        return _imageManager;
    }
    
    return [PHImageManager defaultManager];
}

- (void)setViewAppeared:(BOOL)viewAppeared {
    _viewAppeared = viewAppeared;
    if (viewAppeared) {
        if (self.livePhotoView.livePhoto) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        } else if (self.playerLayer.player) {
            [self.playerLayer.player play];
        }
    } else {
        [self.livePhotoView stopPlayback];
        [self.player pause];
    }
}

@end
