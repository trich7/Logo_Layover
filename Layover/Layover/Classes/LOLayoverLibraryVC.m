//
//  LOLayoverLibraryVC.m
//  Layover
//
//  Created by threek on 5/24/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import "LOLayoverLibraryVC.h"


#define localLayoverImageCount    12

@interface LOLayoverLibraryVC () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *arrayMoreLayoverImages;
    NSString *filePath;
    
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;


@end

@implementation LOLayoverLibraryVC

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
    
    [self createDirectory];
    
    [self checkingMoreLayoverImages];
    
}

- (void) createDirectory
{
    BOOL isDirectory;
    filePath = [self getPathOfDirectory];
//    NSString *dirName = @"layoverImages";
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [fileManager createDirectoryAtPath:filePath
               withIntermediateDirectories:YES
                                attributes:attr
                                     error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
}

- (void) checkingMoreLayoverImages
{
    if (arrayMoreLayoverImages) {
        [arrayMoreLayoverImages removeAllObjects];
        arrayMoreLayoverImages = nil;
    }
    arrayMoreLayoverImages = [[NSMutableArray alloc] init];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
    
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"layoverImages/"];
    
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:filePath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        NSLog(@"%@", filename);
        [arrayMoreLayoverImages addObject:[filePath stringByAppendingString:filename]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) cancelAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UICollectionView datasource & delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    NSString *filename;
    UIImage  *image;
    
    if (indexPath.row < localLayoverImageCount) {
        filename = [NSString stringWithFormat:@"layover%d.png", (int)indexPath.row];
        image = [UIImage imageNamed:filename];
    }
    else {
        filename = [arrayMoreLayoverImages objectAtIndex:(indexPath.row - localLayoverImageCount)];
        image = [UIImage imageWithContentsOfFile:filename];
    }
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:289];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [imageView setContentMode:(UIViewContentModeScaleAspectFit)];
        //// border and shadow
        imageView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        imageView.layer.borderWidth = 1;
        [imageView setTag:289];
    }
    [imageView setImage:image];
    
    //    imageView.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.8].CGColor;
//    imageView.layer.shadowRadius = 5;
//    imageView.layer.shadowOffset = CGSizeMake(5, 5);
    
    // add to cell
    [cell addSubview:imageView];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int cellCount = localLayoverImageCount + (int)arrayMoreLayoverImages.count;
    return cellCount;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"string %d", (int)indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[[cell subviews] objectAtIndex:1];
    if ([imageView isKindOfClass:[UIImageView class]]) {
        if ([self.delegate respondsToSelector:@selector(LayoverLibraryImage:)]) {
            [self.delegate LayoverLibraryImage:imageView.image];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - Add layover image action

- (IBAction) addLayoverImageAction:(id)sender
{
    [self openPhotoAlbum];
}

- (void) openPhotoAlbum
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    //    [imagePicker setAllowsEditing:YES];
    [imagePicker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerViewController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = info[UIImagePickerControllerOriginalImage];

    NSString *filename = [NSString stringWithFormat:@"layoverImage%d.png", (localLayoverImageCount + (int)arrayMoreLayoverImages.count)];
    NSString *fullPathname = [self writeImage:photo filename:filename];
    if (fullPathname) {
        [arrayMoreLayoverImages addObject:fullPathname];
        [self.collectionView reloadData];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (NSString *) writeImage:(UIImage *)image filename:(NSString *)filename
{
    if (!image || !filename || filename.length == 0) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fullPathName = [filePath stringByAppendingString:filename];
    [imageData writeToFile:fullPathName atomically:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:fullPathName forKey:kLastLayoverFilename];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return fullPathName;
}

- (NSString *) getPathOfDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentsDirectory stringByAppendingString:@"/layoverImages/"];
//    NSString *path = [NSString stringWithFormat:@"file:///%@/layoverImages/", documentsDirectory];
    
    return path;
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
