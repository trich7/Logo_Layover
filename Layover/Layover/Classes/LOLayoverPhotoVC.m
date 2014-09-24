//
//  LOLayoverPhotoVC.m
//  Layover
//
//  Created by threek on 5/23/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOLayoverPhotoVC.h"
#import "LOLayoverLibraryVC.h"
#import "LOFinalVC.h"

@interface LOLayoverPhotoVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LOLayoverLibraryVCDelegate>
{
    CGPoint originalPointOfLayoverImageView;
    float   originalScaleOfLayoverImageView;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem  *btnBack;

@property (nonatomic, strong) IBOutlet UIButton         *btnCapture;

@property (nonatomic, strong) IBOutlet UIButton         *btnLayoverAlbum;

@property (nonatomic, strong) IBOutlet UIButton         *btnLayoverGallery;

@property (nonatomic, strong) IBOutlet UIButton         *btnNext;

@property (nonatomic, strong) IBOutlet UIImageView      *imgviewPhoto;

@property (nonatomic, strong) IBOutlet UIImageView      *imgviewLayover;

@end

@implementation LOLayoverPhotoVC

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
    
    if (self.imgBasePhoto) {
        [self.imgviewPhoto setImage:self.imgBasePhoto];
    }
    if (self.imgLastImageOfGallery) {
        [self.btnLayoverGallery setBackgroundImage:self.imgLastImageOfGallery forState:(UIControlStateNormal)];
    }
    
    [self addGestureToLayoverImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    UIImage *image;
    if ([userDefault objectForKey:kLastLayoverFilename]) {
        NSString *filename = [userDefault objectForKey:kLastLayoverFilename];
        image = [UIImage imageWithContentsOfFile:filename];
    }
    else {
        image = [UIImage imageNamed:@"layover11.png"];
    }
    
    [self.btnLayoverAlbum setBackgroundImage:image forState:(UIControlStateNormal)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addGestureToLayoverImageView
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panActionOfLayoverImageView:)];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchActionOfLayoverImageView:)];
    
    [self.imgviewLayover addGestureRecognizer:panGesture];
    [self.imgviewLayover addGestureRecognizer:pinchGesture];
    
}

#pragma mark - Layover ImageView pan & pinch gesture action

- (void) panActionOfLayoverImageView:(UIPanGestureRecognizer *)gesture
{
//    static float dx, dy;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalPointOfLayoverImageView = gesture.view.center;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
//        gesture.
        CGPoint tapPoint = [gesture translationInView:self.view];
        gesture.view.center = CGPointMake(originalPointOfLayoverImageView.x + tapPoint.x,
                                          originalPointOfLayoverImageView.y + tapPoint.y);
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGRect rect = CGRectInset(self.imgviewPhoto.frame,
                                  -gesture.view.frame.size.width * 0.5,
                                  -gesture.view.frame.size.height * 0.5);
        if (!CGRectContainsPoint(rect, gesture.view.center)) {
            gesture.view.center = self.imgviewPhoto.center;
        }
    }
}

- (void) pinchActionOfLayoverImageView:(UIPinchGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        originalScaleOfLayoverImageView = 1.0f;
    }
    CGFloat currentscale = 1.0f - (originalScaleOfLayoverImageView - [gesture scale]);
    CGAffineTransform currentTransform = gesture.view.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, currentscale, currentscale);
    [gesture.view setTransform:newTransform];
    originalScaleOfLayoverImageView = [gesture scale];

}

#pragma mark - UIButton Actions

- (IBAction) backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) nextAction:(id)sender
{
    [self performSegueWithIdentifier:@"gotoFinalVC" sender:nil];
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
    [imagePicker setAllowsEditing:YES];
    
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
    [imagePicker setAllowsEditing:YES];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//    [imagePicker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
//        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//    }
//    else {
//        [imagePicker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
//        
//    }
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void) setImageToLayoverImageview:(UIImage *)image
{
    float dt = image.size.height / image.size.width;
    CGRect rect = self.imgviewLayover.frame;
    float  w = 250;
    
    rect.size = CGSizeMake(w, w * dt);
    
    [self.imgviewLayover setFrame:rect];
    [self.imgviewLayover setImage:[image scaleAndRotateImage]];
    [self.imgviewLayover setHidden:NO];

}

#pragma mark - UIImagePickerViewController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    
    [self setImageToLayoverImageview:photo];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - LOLayoverLibraryVC delegate

- (void)LayoverLibraryImage:(UIImage *)selectedImage
{
    if (selectedImage) {
        [self setImageToLayoverImageview:selectedImage];
    }
}

#pragma mark - Image Transfer

-(UIImage *)resizeImage:(UIImage*)image scaleToSize:(CGSize)newSize
{
    // Create a bitmap context.
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage overayRect:(CGRect)overlayRect
{
    UIImage *image = nil;
    
    //    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(firstImage.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(firstImage.size);
    }
    [firstImage drawAtPoint:CGPointMake(0, 0)];
    //    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
    //                                         roundf((newImageSize.height-secondImage.size.height)/2))];
    [secondImage drawInRect:overlayRect blendMode:(kCGBlendModeNormal) alpha:1];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) mergedImage
{
    if (self.imgviewPhoto.image) {
        if (self.imgviewLayover.image) {
            float dt = self.imgviewPhoto.image.size.width / self.imgviewPhoto.frame.size.width;
            CGRect overlayRect = self.imgviewLayover.frame;
            
            CGSize size = CGSizeMake(overlayRect.size.width  * dt,
                                     overlayRect.size.height * dt);
            
//            UIImage *overlayImage = [self resizeImage:self.imgviewLayover.image scaleToSize:size];
            UIImage *overlayImage = self.imgviewLayover.image; //[self.imgviewLayover.image scaleToSize:size];
            
            CGRect rect = CGRectMake(overlayRect.origin.x * dt, overlayRect.origin.y * dt, size.width, size.height);
            return [self imageByCombiningImage:self.imgviewPhoto.image withImage:overlayImage overayRect:rect];
        }
        else {
            return self.imgviewLayover.image;
        }
    }
    else {
        return nil;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoLayoverLibraryVC"]) {
        UINavigationController *nav = segue.destinationViewController;
        LOLayoverLibraryVC *vc = (LOLayoverLibraryVC *) nav.topViewController;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"gotoFinalVC"]) {
        LOFinalVC *vc = segue.destinationViewController;
        vc.imgFinalPhoto = [self mergedImage];
    }
}


@end
