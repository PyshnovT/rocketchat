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
    UIImage *image = [self scaleAndRotateImage:originalPhoto];
    
    [[RTCMediaStore sharedStore] addTakenPhoto:image];
    

    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
    [self.mvc sendTakenPhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
}

- (UIImage *)scaleAndRotateImage:(UIImage *) image {
    int kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
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
        
        [self setupTransformForHeight:[UIScreen mainScreen].bounds.size.width];
    } else {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.delegate = self;
    
}

- (void)setupTransformForHeight:(CGFloat)height {
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, (height - 426) / 2.0);
    self.cameraViewTransform = translate;
    
    CGFloat scaleFactor = 1.333333;
    CGAffineTransform scale = CGAffineTransformScale(translate, scaleFactor, scaleFactor);
    self.cameraViewTransform = scale;
    
}

- (void)setupOverlayViewFrame {
    CGFloat x, y, width, height;
    
    x = 0;
    width = self.view.bounds.size.width;
    height = self.overlayView.bounds.size.height;
    
    if (self.screenMode == PhotoScreenModeFull) {
        y = self.view.bounds.size.height - self.overlayView.bounds.size.height;
        
        self.overlayView.frame = CGRectMake(x, y, width, height);
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
    
    NSLog(@"sender %@", sender);
    if (self.screenMode == PhotoScreenModeShort) {
        
        [self setupTransformForHeight:[UIScreen mainScreen].bounds.size.height];

        
        [self.screenModeButton setImage:[UIImage imageNamed:@"fullscreen_close"] forState:UIControlStateNormal];

        [self.mvc setPhotoTakerControllerFullScreenMode];
        
    } else if (self.screenMode == PhotoScreenModeFull) {
        
        [self setupTransformForHeight:[UIScreen mainScreen].bounds.size.width];
        
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
