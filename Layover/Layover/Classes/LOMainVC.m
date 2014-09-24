//
//  LOMainVC.m
//  Layover
//
//  Created by threek on 5/23/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOMainVC.h"
#import "GADInterstitial.h"
#import "GADBannerView.h"
#import "MZFormSheetController.h"
#import "LOWelcomeVC.h"


@interface LOMainVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADInterstitialDelegate>
{
    GADInterstitial *interstitial_;
//    GADBannerView *bannerView_;
}

@property (nonatomic, strong) IBOutlet UIButton     *btnStart;

@property (nonatomic, strong) IBOutlet UIButton     *btnOverlayLibrary;

@property (nonatomic, strong) IBOutlet UIButton     *btnFinalLibrary;


@end

@implementation LOMainVC

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
    
    [self initAdMob];

    [self showWelcomeScreen];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initAdMob
{
//    // Create a view of the standard size at the top of the screen.
//    // Available AdSize constants are explained in GADAdSize.h.
//    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//    
//    // Specify the ad unit ID.
//    bannerView_.adUnitID = AdMobAppID;
//    
//    // Let the runtime know which UIViewController to restore after taking
//    // the user wherever the ad goes and add it to the view hierarchy.
//    bannerView_.rootViewController = self;
//    [self.view addSubview:bannerView_];
//    
//    // Initiate a generic request to load it with an ad.
//    [bannerView_ loadRequest:[GADRequest request]];
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = AdMobAppID1;
    [interstitial_ loadRequest:[GADRequest request]];
    interstitial_.delegate = self;

}

#pragma mark - AdMob delegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self showAdMob:0];
//    int dt = random() % 30;
//    [NSTimer scheduledTimerWithTimeInterval:dt target:self selector:@selector(showAdMob:) userInfo:nil repeats:NO];
    NSLog(@"show admob : %d", 0);
    
}

- (void) showAdMob:(float) dt
{
    [interstitial_ presentFromRootViewController:self.navigationController];
}

#pragma mark - Show Welcome screen

- (void) showWelcomeScreen
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefault boolForKey:@"welcome"];
    if (flag) {
        return;
    }
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
//    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.8f]];

    LOWelcomeVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
    
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:vc];
    rootVC.navigationBarHidden = YES;
    rootVC.navigationBar.translucent = NO;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:rootVC];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
    
    [userDefault setBool:YES forKey:@"welcome"];
    [userDefault synchronize];
}

#pragma mark -

- (IBAction) openLayoverLibraryAction:(id)sender
{
//    self per
}

- (IBAction) openFinishedLibrary:(id)sender
{
    [self openPhotoAlbum];
}

- (void) openPhotoAlbum
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    //    [imagePicker setAllowsEditing:YES];
    
    //    [imagePicker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    

    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerViewController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *photo = info[UIImagePickerControllerOriginalImage];
//    
//    float dt = photo.size.height / photo.size.width;
//    CGRect rect = self.imgviewLayover.frame;
//    float  w = 250;
//    
//    if (dt > 1) {
//        rect.size = CGSizeMake(w, w * dt);
//    }
//    else {
//        rect.size = CGSizeMake(w * (1 / dt), w);
//    }
//    
//    [self.imgviewLayover setFrame:rect];
//    [self.imgviewLayover setImage:[photo scaleAndRotateImage]];
//    [self.imgviewLayover setHidden:NO];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
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
