//
//  FSInternalPickerViewController.m
//  FSImagePicker
//
//  Created by Vahan Babayan on 2/2/18.
//

#import "FSInternalPickerViewController.h"

#import <Photos/Photos.h>
#import "UIView+FSAdditions.h"
#import "FSImagePickerCollectionViewCell.h"
#import "FSImagePickerPreviewingViewController.h"

FSImagePickerInfo const FSImagePickerInfoCancelled = @"FSImagePickerInfoKeyCancelled";
FSImagePickerInfo const FSImagePickerInfoPickedItems = @"FSImagePickerInfoKeyPickedItems";

static NSString *const FSImagePickerCollectionViewCellReuseID = @"FSImagePickerCollectionViewCellReuseIdentifier";
static NSString *const FSIconsBundleName = @"Icons";
static NSString *const FSThumbnailIconName = @"Thumbnail";

static const NSUInteger NumberOfColumns = 4;
static const CGFloat Spacing = 3.0;

@interface FSInternalPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UIViewControllerPreviewingDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *dialogContainerView;
@property (nonatomic, weak) UIImageView *dialogIconImageView;
@property (nonatomic, weak) UILabel *dialogLabel;
@property (nonatomic, weak) UIBarButtonItem *rightBarButtonItem;

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHImageRequestOptions *imageRequestOptions;
@property (nonatomic) PHFetchResult<PHAsset *> *assets;
@property (nonatomic) dispatch_queue_t changeObservingQueue;

@property (nonatomic) id<UIViewControllerPreviewing> vcPreviewing;

@property (nonatomic) FSImagePickerViewController *navigationController;

@end

@implementation FSInternalPickerViewController

@dynamic navigationController;

#pragma mark - Initialization

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *changeQueueID = [([NSBundle bundleForClass:[self class]].bundleIdentifier ?: @"unknown") stringByAppendingString:@".ImagePicker.PhotosObserving"];
    dispatch_queue_attr_t changeQueueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, QOS_MIN_RELATIVE_PRIORITY);
    self.changeObservingQueue = dispatch_queue_create(changeQueueID.UTF8String, changeQueueAttr);
    self.imageManager = [PHCachingImageManager new];
    self.imageRequestOptions = [PHImageRequestOptions new];
    
    UIView *dialogContainerView = [[UIView alloc] init];
    dialogContainerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    dialogContainerView.alpha = 0.0;
    UIImageView *dialogIconImageView = [[UIImageView alloc] init];
    dialogIconImageView.tintColor = [UIColor whiteColor];
    dialogIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *dialogLabel = [[UILabel alloc] init];
    dialogLabel.font = [UIFont systemFontOfSize:17.0];
    dialogLabel.textColor = [UIColor whiteColor];
    dialogLabel.numberOfLines = 0;
    dialogLabel.textAlignment = NSTextAlignmentCenter;
    
    [dialogContainerView addSubview:dialogIconImageView];
    [dialogContainerView addSubview:dialogLabel];
    dialogIconImageView.translatesAutoresizingMaskIntoConstraints = dialogLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [dialogIconImageView.centerXAnchor constraintEqualToAnchor:dialogContainerView.centerXAnchor],
                                              [dialogIconImageView.centerYAnchor constraintEqualToAnchor:dialogContainerView.centerYAnchor],
                                              [dialogIconImageView.widthAnchor constraintEqualToAnchor:dialogContainerView.widthAnchor multiplier:0.6],
                                              [dialogIconImageView.heightAnchor constraintEqualToAnchor:dialogContainerView.widthAnchor multiplier:0.6],
                                              
                                              [dialogLabel.topAnchor constraintEqualToAnchor:dialogIconImageView.bottomAnchor constant:8.0],
                                              [dialogLabel.centerXAnchor constraintEqualToAnchor:dialogIconImageView.centerXAnchor],
                                              [NSLayoutConstraint constraintWithItem:dialogLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:dialogContainerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-16.0],
                                              [NSLayoutConstraint constraintWithItem:dialogLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:dialogContainerView attribute:NSLayoutAttributeBottomMargin multiplier:1.0 constant:-8.0]
                                              ]];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = Spacing;
    flowLayout.minimumInteritemSpacing = Spacing;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.contentInset = UIEdgeInsetsMake(Spacing, Spacing, Spacing, Spacing);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.allowsMultipleSelection = YES;
    collectionView.alwaysBounceVertical = YES;
    [collectionView registerClass:[FSImagePickerCollectionViewCell class] forCellWithReuseIdentifier:FSImagePickerCollectionViewCellReuseID];
    
    [self.view addSubview:dialogContainerView];
    [dialogContainerView fs_fillSuperview];
    [self.view addSubview:collectionView];
    [collectionView fs_fillSuperview];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.title = @"Camera Roll";
    
    self.dialogContainerView = dialogContainerView;
    self.dialogIconImageView = dialogIconImageView;
    self.dialogLabel = dialogLabel;
    self.collectionView = collectionView;
    self.rightBarButtonItem = rightBarButtonItem;
    
    [self setupForceTouch];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self fetchAllAssets];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        __weak typeof(self) welf = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                __strong typeof(self) sself = welf;
                if (!sself) { return; }
                [sself fetchAllAssets];
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:sself];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf.collectionView reloadData];
            });
        }];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability != UIForceTouchCapabilityAvailable && self.vcPreviewing) {
            [self unregisterForPreviewingWithContext:self.vcPreviewing];
            self.vcPreviewing = nil;
        } else {
            [self setupForceTouch];
        }
    }
}

- (void)showDialogWithMessage:(NSString *)message icon:(UIImage *)icon animated:(BOOL)animated {
    if (animated) {
        __weak typeof(self) welf = self;
        [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [welf showDialogWithMessage:message icon:icon];
        } completion:nil];
    } else {
        [self showDialogWithMessage:message icon:icon];
    }
}

- (void)showDialogWithMessage:(NSString *)message icon:(UIImage *)icon {
    self.dialogIconImageView.image = icon;
    self.dialogLabel.text = message;
    self.dialogContainerView.alpha = 1.0;
    self.collectionView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.collectionView.alpha = 0.0;
}

- (void)fetchAllAssets {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    NSString *predicateString;
    if (self.mediaType & FSImagePickerMediaTypesLivePhoto) {
        if (self.mediaType & FSImagePickerMediaTypesPhoto) {
            predicateString = @"((mediaType == %i) || (mediaSubtype == %i))";
        } else {
            predicateString = @"((mediaType == %i) && (mediaSubtype == %i))";
        }
    } else if (self.mediaType & FSImagePickerMediaTypesPhoto) {
        predicateString = @"((mediaType == %i) && !(mediaSubtype == %i))";
    } else {
        predicateString = @"!(mediaType == %i) && !(mediaSubtype == %i)";
    }
    
    if (self.mediaType & FSImagePickerMediaTypesVideo) {
        predicateString = [predicateString stringByAppendingString:@" || (mediaType == %i)"];
    } else {
        predicateString = [predicateString stringByAppendingString:@" && !(mediaType == %i)"];
    }
    
    fetchOptions.predicate = [NSPredicate predicateWithFormat:predicateString, PHAssetMediaTypeImage, PHAssetMediaSubtypePhotoLive, PHAssetMediaTypeVideo];
    self.assets = [PHAsset fetchAssetsWithOptions:fetchOptions];
}

- (void)setupForceTouch {
    self.vcPreviewing = nil;
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            self.vcPreviewing = [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        }
    }
}

- (void)updateVisibleItems {
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
}

#pragma mark - Actions

- (void)leftBarButtonAction:(UIBarButtonItem *)sender {
    if (self.collectionView.indexPathsForSelectedItems.count) {
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
        }
    } else {
        for (NSUInteger i = 0; i < self.assets.count; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        }
    }
}

- (void)rightBarButtonAction:(UIBarButtonItem *)sender {
    __weak typeof(self) welf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(welf) sself = welf;
        __strong typeof(sself.delegate) delegate = sself.delegate;
        if ([delegate respondsToSelector:@selector(imagePicker:didFinishPickingMediaWithInfo:)]) {
            if (sself.collectionView.indexPathsForSelectedItems.count) {
                NSMutableArray<PHAsset *> *pickedItems = [NSMutableArray arrayWithCapacity:sself.collectionView.indexPathsForSelectedItems.count];
                for (NSIndexPath *indexPath in sself.collectionView.indexPathsForSelectedItems) {
                    [pickedItems addObject:sself.assets[indexPath.item]];
                }
                [delegate imagePicker:sself.navigationController didFinishPickingMediaWithInfo:@{
                                                                            FSImagePickerInfoPickedItems: [pickedItems copy]
                                                                            }];
            } else {
                [delegate imagePicker:sself.navigationController didFinishPickingMediaWithInfo:@{
                                                                            FSImagePickerInfoCancelled: @YES
                                                                            }];
            }
            
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.assets.count) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        NSURL *iconsBundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:FSIconsBundleName withExtension:@"bundle"];
        NSBundle *iconsBundle = [NSBundle bundleWithURL:iconsBundleURL];
        UIImage *placeholder = [UIImage imageNamed:FSThumbnailIconName inBundle:iconsBundle compatibleWithTraitCollection:nil];
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self showDialogWithMessage:@"It looks like you have not saved any media yet." icon:placeholder animated:YES];
                break;
            case PHAuthorizationStatusDenied:
                [self showDialogWithMessage:@"It looks like we have not access to the media library." icon:placeholder animated:YES];
                break;
            case PHAuthorizationStatusRestricted:
                [self showDialogWithMessage:@"It looks like access to the media library was restricted on the devices." icon:placeholder animated:YES];
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"Strange behaviour in %s at %d.", __PRETTY_FUNCTION__, __LINE__);
                break;
        }
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FSImagePickerCollectionViewCellReuseID forIndexPath:indexPath];
    cell.selectedBackgroundView.backgroundColor = self.navigationController.selectionColor;
    
    PHAsset *asset = self.assets[indexPath.item];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.type = FSImagePickerCollectionViewCellTypeVideo;
        cell.duration = asset.duration;
    } else if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        cell.type = FSImagePickerCollectionViewCellTypeLivePhoto;
    } else {
        cell.type = FSImagePickerCollectionViewCellTypePhoto;
    }
    
    cell.tag = indexPath.item;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(collectionView.bounds.size.width / 4.0, collectionView.bounds.size.height / 4.0)
                                contentMode:PHImageContentModeAspectFill
                                    options:self.imageRequestOptions
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if(cell.tag == indexPath.item){
                                          cell.image = result;
                                      }
                                  });
                              }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.rightBarButtonItem.title = @"Done";
    self.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    
    self.navigationItem.leftBarButtonItem.title = @"Deselect";
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!collectionView.indexPathsForSelectedItems.count) {
        self.rightBarButtonItem.title = @"Cancel";
        self.rightBarButtonItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem.title = @"Select All";
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat side = (collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right - (NumberOfColumns - 1) * Spacing) / NumberOfColumns;
    return CGSizeMake(side, side);
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) { return nil; }
    
    FSImagePickerCollectionViewCell *cell = (FSImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    previewingContext.sourceRect = cell.frame;
    
    FSImagePickerPreviewingViewController *previewingVC = [[FSImagePickerPreviewingViewController alloc] init];
    [previewingVC setAsset:self.assets[indexPath.item] withPreviewImage:cell.image];
    
    return previewingVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(FSImagePickerPreviewingViewController *)viewControllerToCommit {
    PHAsset *asset = viewControllerToCommit.asset;
    if (!asset) { return; }
    NSUInteger idx = [self.assets indexOfObject:asset];
    if (idx == NSNotFound) { return; }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
    
    if ([self.collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:self.assets];
    if (!details) { return; }
    
    __weak typeof(self) welf = self;
    dispatch_async(self.changeObservingQueue, ^{
        __strong typeof(welf) sself = welf;
        if (!sself) { return; }
        
        sself.assets = details.fetchResultAfterChanges;
        if (!details.hasIncrementalChanges) {
            [sself.collectionView reloadData];
            return;
        }
        
        NSIndexSet *removedIndices = details.removedIndexes;
        NSIndexSet *insertedIndices = details.insertedIndexes;
        NSIndexSet *changedIndices = details.changedIndexes;
        
        NSMutableArray<NSIndexPath *> *removedIndexPaths = [NSMutableArray arrayWithCapacity:removedIndices.count];
        if (removedIndices) {
            [removedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [removedIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            }];
        }
        NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:insertedIndices.count];
        if (insertedIndices) {
            [insertedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            }];
        }
        NSMutableArray *changedIndexPaths = [NSMutableArray arrayWithCapacity:changedIndices.count];
        if (changedIndices) {
            [changedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [changedIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf.collectionView performBatchUpdates:^{
                if (removedIndexPaths.count) {
                    [welf.collectionView deleteItemsAtIndexPaths:removedIndexPaths];
                }
                if (insertedIndexPaths.count) {
                    [welf.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
                }
            } completion:^(BOOL finished) {
                if (!finished) {
                    [welf.collectionView reloadData];
                    return;
                }
                
                if (changedIndexPaths.count) {
                    [welf.collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                }
                
                if ([details hasMoves]) {
                    [welf.collectionView performBatchUpdates:^{
                        [details enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                            [welf.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                        }];
                    } completion:nil];
                }
            }];
        });
    });
}

@end
