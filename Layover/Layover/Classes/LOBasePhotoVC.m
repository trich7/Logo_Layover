//
//  LOBasePhotoVC.m
//  Layover
//
//  Created by threek on 5/23/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOBasePhotoVC.h"
#import "LOLayoverPhotoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface LOBasePhotoVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem  *btnBack;

@property (nonatomic, strong) IBOutlet UIButton         *btnCapture;

@property (nonatomic, strong) IBOutlet UIButton         *btnPhotoAlbum;

//@property (nonatomic, strong) IBOutlet UIButton         *btnOverlayAlbum;

@property (nonatomic, strong) IBOutlet UIButton         *btnNext;

@property (nonatomic, strong) IBOutlet UIScrollView     *scrviewPhotoContainer;

@property (nonatomic, strong) IBOutlet UIImageView      *imgviewPhoto;

//@property (nonatomic, strong) IBOutlet UIImageView      *imgviewOverlay;


@end

@implementation LOBasePhotoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadLastPhotoFromCameraroll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadLastPhotoFromCameraroll
{
    /*
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                // Do something interesting with the AV asset.
                // [self sendTweet:latestPhoto];
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
    */
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (nil != group) {
                                         // be sure to filter the group so you only get photos
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         
                                         
                                         [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                 options:0
                                                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                  if (nil != result) {
                                                                      ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                      // this is the most recent saved photo
                                                                      UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                      // we only need the first (most recent) photo -- stop the enumeration
                                                                      if (img) {
                                                                          [self.btnPhotoAlbum setBackgroundImage:img forState:(UIControlStateNormal)];
                                                                      }
                                                                      *stop = YES;
                                                                  }
                                                              }];
                                     }
                                     
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                 }];

}

- (IBAction) backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) nextAction:(id)sender
{
    if (self.imgviewPhoto.image) {
        [self performSegueWithIdentifier:@"gotoLayoverPhotoVC" sender:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Select or Capture Base photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction) capturePhotoAction:(id)sender
{
    [self showCameraController];
}

- (IBAction) photoAlbumAction:(id)sender
{
    [self openPhotoAlbum];
}

- (void) showCameraController
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
//    [imagePicker setAllowsEditing:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"NO CAMERA!");
    }

}

- (void) openPhotoAlbum
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    //    [imagePicker setAllowsEditing:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    else {
        [imagePicker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
        
    }
    [self presentViewController:imagePicker animated:YES completion:nil];

}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == self.scrviewPhotoContainer) {
        return self.imgviewPhoto;
    } else {
        return Nil;
    }
}


#pragma mark - UIImagePickerViewController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = info[UIImagePickerControllerOriginalImage];
    float dt = photo.size.height / photo.size.width;
    CGRect rect = self.imgviewPhoto.frame;
    if (dt > 1) {
        rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width * dt);
    }
    else {
        rect.size = CGSizeMake(self.view.frame.size.width * (1 / dt), self.view.frame.size.width);
    }
    
    [self.imgviewPhoto setFrame:rect];
    [self.imgviewPhoto setImage:photo];
    
    [self.scrviewPhotoContainer setContentSize:rect.size];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - Image Transfer

- (UIImage*) croppedNewImage
{
//    UIImage *image = [self scaleAndRotateImage:self.imgviewPhoto.image];
    UIImage *image = [self.imgviewPhoto.image scaleAndRotateImage];
    if (image) {
        CGPoint offset = self.scrviewPhotoContainer.contentOffset;
        CGSize imageSize = image.size;
        CGSize imageViewSize = self.imgviewPhoto.frame.size;
        float ds = imageViewSize.width / imageSize.width;

        float xx1 = (1 / ds) * offset.x,
              yy1 = (1 / ds) * offset.y;
        
        float ww1 = (1 / ds) * self.scrviewPhotoContainer.frame.size.width,
              hh1 = (1 / ds) * self.scrviewPhotoContainer.frame.size.height;
        
        CGRect cropRect = CGRectMake(xx1, yy1, ww1, hh1);

        CGImageRef imageref = CGImageCreateWithImageInRect([image CGImage], cropRect);
        UIImage *cropImage = [UIImage imageWithCGImage:imageref];
        return cropImage;
        
    } else {
        return nil;
    }
    
}

- (UIImage*)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 1024; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    [self setRotatedImage:imageCopy];
    return imageCopy;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoLayoverPhotoVC"]) {
        LOLayoverPhotoVC *vc = segue.destinationViewController;
        vc.imgBasePhoto = [self croppedNewImage];
        vc.imgLastImageOfGallery = [self.btnPhotoAlbum backgroundImageForState:(UIControlStateNormal)];
    }
}


@end
