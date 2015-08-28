//
//  RTCImagePickerViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 28/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCImagePickerViewController.h"
#import "RTCMediaStore.h"
#import "RTCCollectionViewController.h"

@interface RTCImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imagePickerScrollView;

@end

@implementation RTCImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePickerScrollView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPhotoFromGallery:(id)sender {
    if ([[RTCMediaStore sharedStore] imageGalleryItems].count == 8) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Количество фотографий" message:@"Нельзя отсылать больше 8 фотографий" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            UIAlertView* finalCheck = [[UIAlertView alloc]
                                       initWithTitle:@"Количество фотографий"
                                       message:@"Нельзя отсылать больше 8 фотографий"
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            
            [finalCheck show];
        }
    } else {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Image Magic

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MAX( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
    
    [image drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    CGFloat sideLength = self.imagePickerScrollView.bounds.size.height - self.imagePickerScrollView.contentInset.top - self.imagePickerScrollView.contentInset.bottom;
    CGFloat interImageY = 5;
    NSInteger uploadedImages = [[RTCMediaStore sharedStore] imageGalleryItems].count;
    
    UIImage *scaledImage = [self scaleImage:originalImage toSize:CGSizeMake(sideLength, sideLength)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat x = uploadedImages * (interImageY + sideLength);
    imageView.frame = CGRectMake(x, 0, sideLength, sideLength);
    
    
    
    CGFloat scrollViewContentWidth = (uploadedImages + 1) * (interImageY + sideLength);
    self.imagePickerScrollView.contentSize = CGSizeMake(scrollViewContentWidth, sideLength);
    [self.imagePickerScrollView addSubview:imageView];
    
    [[RTCMediaStore sharedStore] addImageFromGallery:originalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
