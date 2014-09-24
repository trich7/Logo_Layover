//
//  LOLayoverLibraryVC.h
//  Layover
//
//  Created by threek on 5/24/14.
//  Copyright (c) 2014 gengshu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LOLayoverLibraryVCDelegate <NSObject>

- (void) LayoverLibraryImage:(UIImage *)selectedImage;

@end

@interface LOLayoverLibraryVC : UIViewController

@property (nonatomic, strong) id<LOLayoverLibraryVCDelegate> delegate;

@end
