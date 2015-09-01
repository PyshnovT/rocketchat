//
//  RTCPhotoTakerController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 30/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCPhotoTakerController.h"
#import "RTCMainViewController.h"

#import "RTCMediaStore.h"

@interface RTCPhotoTakerController ()

@property (strong, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation RTCPhotoTakerController 

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupPhotoTakerController];
    }
    return self;
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalPhoto = info[UIImagePickerControllerOriginalImage];
    [[RTCMediaStore sharedStore] addTakenPhoto:originalPhoto];
    

    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
    [self.mvc sendTakenPhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
}

- (UIView *)cameraOverlayView {
    if (!_overlayView) {
        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
    }
    
    return _overlayView;
}

- (void)setupPhotoTakerController {
    if ([RTCPhotoTakerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = NO;
        
        self.overlayView.frame = CGRectMake(0, self.view.bounds.size.width - self.overlayView.bounds.size.height, self.view.bounds.size.width, self.overlayView.bounds.size.height);
        self.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
    } else {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.delegate = self;
    
}

- (void)setupOverlayViewFrame {
    CGFloat x, y, width, height;
    
    x = 0;
    width = self.view.bounds.size.width;
    height = self.overlayView.bounds.size.height;
    
    if (self.screenMode == PhotoScreenModeFull) {
        y = self.view.bounds.size.width - self.overlayView.bounds.size.height;
        
        self.overlayView.frame = CGRectMake(0, y, width, height);
    } else {
        y = self.view.bounds.size.width - self.overlayView.bounds.size.height;
        
        self.overlayView.frame = CGRectMake(x, y, width, height);
    }
}

- (IBAction)takePhoto:(id)sender {
    [self takePicture];
}

- (IBAction)changePhotoTakerScreenMode:(id)sender {
    [self setupOverlayViewFrame];
    
    if (self.screenMode == PhotoScreenModeShort) {
        
        ((UIButton *)sender).imageView.image = [UIImage imageNamed:@"fullscreen_close"];
        [self.mvc setPhotoTakerControllerFullScreenMode];
        
    } else if (self.screenMode == PhotoScreenModeFull) {
        
        ((UIButton *)sender).imageView.image = [UIImage imageNamed:@"camera_interface_fullscreen"];
        [self.mvc setPhotoTakerControllerShortScreenMode];
        
    }
}

- (IBAction)switchCamera:(id)sender {
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else if (self.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

@end
