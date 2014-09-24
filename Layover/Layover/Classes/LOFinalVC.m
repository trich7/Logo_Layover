//
//  LOFinalVC.m
//  Layover
//
//  Created by threek on 5/23/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOFinalVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "GADInterstitial.h"

@interface LOFinalVC () <MFMailComposeViewControllerDelegate, GADInterstitialDelegate>
{
    GADInterstitial *interstitial_;
}

@property (nonatomic, strong) IBOutlet  UIImageView     *imgviewFinalPhoto;

@property (strong, nonatomic) ALAssetsLibrary* library;

@end

@implementation LOFinalVC

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
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = AdMobAppID2;
    [interstitial_ loadRequest:[GADRequest request]];
    interstitial_.delegate = self;
    
    
    if (self.imgFinalPhoto) {
        [self.imgviewFinalPhoto setImage:self.imgFinalPhoto];
    }
    
    self.library = [[ALAssetsLibrary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AdMob delegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [interstitial_ presentFromRootViewController:self.navigationController];
    NSLog(@"show admob");
}

#pragma mark -

- (IBAction) backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) doneAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (IBAction) saveToiPhonePictures:(id)sender
{
    if (self.imgFinalPhoto) {
        UIImageWriteToSavedPhotosAlbum(self.imgFinalPhoto, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

    }
}

- (IBAction) saveToFinishedPicturesLibrary:(id)sender
{
    if (self.imgFinalPhoto) {
//        [self.library addAssetsGroupAlbumWithName:@"my album 3K" resultBlock:^(ALAssetsGroup *group) {
//            NSLog(@"success!");
//        } failureBlock:^(NSError *error) {
//            NSLog(@"error!");
//        }];
        
        [self.library saveImage:self.imgFinalPhoto toAlbum:@"Finished Pictures" withCompletionBlock:^(NSError *error) {
            if (error) {
                NSLog(@"Big error: %@", [error description]);
                [self showErrorAlert:error];
            }
            else {
                [self showSuccessAlert];
            }
        }];

    }
}

- (IBAction) shareToTwitterAction:(id)sender
{
    if (self.imgFinalPhoto) {
        [self sharetoTwitter:self.imgFinalPhoto];
    }
}

- (IBAction) shareToFacebookAction:(id)sender
{
    if (self.imgFinalPhoto) {
        [self sharetoFacebook:self.imgFinalPhoto];
    }
}

- (IBAction) shareToEmailAction:(id)sender
{
    if (self.imgFinalPhoto)
        [self shareViaEmail:self.imgFinalPhoto];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    //NSLog(@"Image:%@", image);
    if (error) {
        [self showErrorAlert:error];
    }
    else
    {
        [self showSuccessAlert];
    }
}

-(void) sharetoTwitter : (UIImage *) image
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I made this picture with the Logo Layover App http://bit.ly/LogoLayover"];
        [tweetSheet addImage:image];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your twitter setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void) sharetoFacebook : (UIImage *) image
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"I made this picture with the Logo Layover App http://bit.ly/LogoLayover"];
        //        [controller addURL:[NSURL URLWithString:@"http://sharee.com"]];
        [controller addImage:image];
        
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your facebook setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

-(void)shareViaEmail :(UIImage *) image
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"Picture Art"];
        [mailView setMessageBody:@"I made this picture with the Logo Layover App http://bit.ly/LogoLayover" isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        NSData *attachmentData = UIImageJPEGRepresentation(image, 1.0);
        [mailView addAttachmentData:attachmentData mimeType:@"image/png" fileName:@"image.png"];
        [self presentViewController:mailView animated:YES completion:nil];
        //        [mailView release];
        
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles: nil];
        [alert show];
    }/* else {
      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Mail transfered successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [self dismissViewControllerAnimated:YES completion:nil];
      } */
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) showErrorAlert:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error! Could not Save Photo to Gallery"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

- (void) showSuccessAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:@"Success! Saved Photo"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];

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
