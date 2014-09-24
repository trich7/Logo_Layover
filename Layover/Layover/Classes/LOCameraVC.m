//
//  LOCameraVC.m
//  Layover
//
//  Created by threek on 5/23/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOCameraVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface LOCameraVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *imagePicker;
    
}

@property (nonatomic, strong) IBOutlet UIView                   *viewCamera;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView  *activityLoader;

@end

@implementation LOCameraVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initMethod
{
    
//    kUTTypeImage
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if(imagePicker)
        {
            imagePicker.delegate = nil;
            imagePicker = nil;
        }
        imagePicker=[[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.delegate = self;
        
//        NSArray *media = [UIImagePickerController
//                          availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        
        imagePicker.allowsEditing = YES;
    
        [imagePicker.view setFrame:self.viewCamera.bounds];
        
        [imagePicker.view setBackgroundColor:[UIColor clearColor]];
        imagePicker.showsCameraControls = YES;
            
        [self.viewCamera addSubview: imagePicker.view];
        
        [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        
    } else {
        NSLog(@"No camera!");
    }
    
    [self.activityLoader stopAnimating];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
