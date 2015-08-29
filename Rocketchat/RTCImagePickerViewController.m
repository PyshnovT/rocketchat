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
#import "RTCImagePickerViewController.h"
#import "RTCMessageImageMediaItem.h"
#import "RTCMainViewController.h"

#import "UIImage+Scale.h"

@interface RTCImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation RTCImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)addImageFromGallery:(id)sender {
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


#pragma mark - Scroll View

- (void)cleanScrollView {
    NSArray *scrollViewSubviews = [self.scrollView subviews];
    
    for (int i = 0; i < scrollViewSubviews.count; i++) {
        if ([scrollViewSubviews[i] isKindOfClass:[UIImageView class]]) {
            [scrollViewSubviews[i] removeFromSuperview];
        }
    }
}

- (void)updateScrollView {
    
    [self cleanScrollView];
    
    CGFloat sideLength = self.scrollView.bounds.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom;
    CGFloat interImageY = 5;
    
    NSArray *uploadedImages = [[RTCMediaStore sharedStore] imageGalleryItems];
    
    for (int i = 0; i < uploadedImages.count; i++) {

        UIImage *originalImage = ((RTCMessageImageMediaItem *)uploadedImages[i]).image;
        
        UIImage *scaledImage = [originalImage scaleImageToFillWithSize:CGSizeMake(sideLength, sideLength)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:scaledImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat x = i * (interImageY + sideLength);
        imageView.frame = CGRectMake(x, 0, sideLength, sideLength);

        [self.scrollView addSubview:imageView];
    }
    
    CGFloat scrollViewContentWidth = uploadedImages.count * (interImageY + sideLength);
    self.scrollView.contentSize = CGSizeMake(scrollViewContentWidth, sideLength);
    
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [[RTCMediaStore sharedStore] addImageFromGallery:originalImage];
    
    [self.mvc setSendButtonColor];
    
    [self updateScrollView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
