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
@property (weak, nonatomic) IBOutlet UIButton *screenModeButton;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupPhotoTakerController];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Dealloc");
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
        
        

        [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
        [self setupOverlayViewFrame];
        self.cameraOverlayView = self.overlayView;
        
        [self setupTransformForHeight:self.view.bounds.size.width];
    } else {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.delegate = self;
    
}

- (void)setupTransformForHeight:(CGFloat)height {
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, (568 - 426) / 2.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
    self.cameraViewTransform = translate;
    
    CGFloat scaleFactor = 1.333333;
    CGAffineTransform scale = CGAffineTransformScale(translate, scaleFactor, scaleFactor);
    self.cameraViewTransform = scale;
    
    NSLog(@"set transform");
}

- (void)setupOverlayViewFrame {
    CGFloat x, y, width, height;
    
    x = 0;
    width = self.view.bounds.size.width;
    height = self.overlayView.bounds.size.height;
    
    if (self.screenMode == PhotoScreenModeFull) {
        NSLog(@"WIDE");
        y = self.view.bounds.size.height - self.overlayView.bounds.size.height;
        NSLog(@"%f", y);
        
        self.overlayView.frame = CGRectMake(x, y, width, height);
        NSLog(@"%@", self.overlayView);
    } else {
        NSLog(@"Short");
        y = self.view.bounds.size.width - self.overlayView.bounds.size.height;
        
        self.overlayView.frame = CGRectMake(x, y, width, height);
    }
}

- (IBAction)takePhoto:(id)sender {
    [self takePicture];
}

- (IBAction)changePhotoTakerScreenMode:(id)sender {
    [self setupOverlayViewFrame];
    
    NSLog(@"sender %@", sender);
    if (self.screenMode == PhotoScreenModeShort) {
        
        [self setupTransformForHeight:self.view.bounds.size.height];
        
        [self.screenModeButton setImage:[UIImage imageNamed:@"fullscreen_close"] forState:UIControlStateNormal];

        [self.mvc setPhotoTakerControllerFullScreenMode];
        
    } else if (self.screenMode == PhotoScreenModeFull) {
        
        [self setupTransformForHeight:self.view.bounds.size.width];
        
        [self.screenModeButton setImage:[UIImage imageNamed:@"camera_interface_fullscreen"] forState:UIControlStateNormal];
        [self.mvc setPhotoTakerControllerShortScreenMode];
        
    }
    
    [self setupOverlayViewFrame];
    //[self setupTransform];
}

- (IBAction)switchCamera:(id)sender {
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else if (self.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

@end
