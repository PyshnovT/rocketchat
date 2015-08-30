//
//  RTCMainViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMainViewController.h"
#import "RTCMessageStore.h"
#import "RTCMessageCollectionViewCell.h"
#import "RTCMessage.h"
#import "RTCMessageCollectionViewLayout.h"
#import "RTCCollectionViewController.h"
#import "RTCMediaStore.h"
#import "RTCImagePickerViewController.h"
#import "RTCMessageImageMediaItem.h"
#import "RTCPhotoTakerController.h"

@interface RTCMainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *controllerCollectionView;
@property (strong, nonatomic) RTCCollectionViewController *collectionViewController;
@property (weak, nonatomic) IBOutlet UIView *mediaContainerView;
@property (weak, nonatomic) IBOutlet UIView *mediaPickerToolbarView;


@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// .ViewController xib

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewToMediaPickerToolbarViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaPickerToolbarViewHeightConstraint;


// Media Buttons

@property (weak, nonatomic) IBOutlet UIButton *photoTakingMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *imageGalleryMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *locationMediaButton;

// Image Picker

@property (strong, nonatomic) RTCImagePickerViewController *imagePickerViewController;

// Photo Taker

@property (strong, nonatomic) RTCPhotoTakerController *photoTakerController;

@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RTCMessageCollectionViewLayout *messageLayout = [[RTCMessageCollectionViewLayout alloc] init];
    self.collectionViewController = [[RTCCollectionViewController alloc]
                                     initWithCollectionViewLayout:messageLayout];
    
    [self displayViewController:self.collectionViewController];
    self.messageTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Notification

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)deregisterFromKeyboardNotifications {
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification                                                  object:nil];
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)note {
    [self updateConstraintsForKeyboardNotification:note];
}

- (void)keyboardDidChangeFrame:(NSNotification *)note {
    [self updateConstraintsForKeyboardNotification:note];
}

- (void)keyboardWillBeShown:(NSNotification *)note {
    [self updateConstraintsForKeyboardNotification:note];
}

- (void)keyboardWillBeHidden:(NSNotification *)note {
    [self updateConstraintsForKeyboardNotification:note];
}

- (void)updateConstraintsForKeyboardNotification:(NSNotification*)note {
    NSDictionary *userInfo = note.userInfo;
    NSLog(@"%@", userInfo);
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    float keyboardHeight = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY([self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil]);
    
    NSLog(@"%f", keyboardHeight);
    
    [self.view layoutIfNeeded];
    
    
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^{
        
        if (self.mediaContainerViewHeightConstraint.constant > 0) {
            // self.mediaContainerViewHeightConstraint.constant = 0;
        }
        
        self.inputToolbarViewToMediaPickerToolbarViewConstraint.constant = MAX(keyboardHeight - self.mediaPickerToolbarViewHeightConstraint.constant - self.mediaContainerViewHeightConstraint.constant, 0);
        
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Displaying Controllers

- (void)displayViewController:(UIViewController *)controller {
    
    [self addChildViewController:controller];
    
    if (controller == self.collectionViewController) {
        
        self.collectionViewController.mvc = self;
        [self.controllerCollectionView addSubview:controller.view];
        [self setConstraintsForCollectionViewController];
        
    } else if (controller == self.imagePickerViewController) {
        
        if ([[RTCMediaStore sharedStore] imageGalleryItems].count) {
            [self setActiveSendButtonColor];
        }
        
        self.imagePickerViewController.mvc = self;
        
        [self.view layoutIfNeeded];
        
        void (^completionBlock)() = ^void() {
          //  self.mediaContainerView.hidden = NO;
            NSLog(@"CompletionBlock!");
            [self.mediaContainerView addSubview:self.imagePickerViewController.view];
            
            [UIView animateWithDuration:0.2 animations:^{
                [self setConstraintsForImagePickerViewController];
                [self.view layoutIfNeeded];
            }];
        };
        
        if ([RTCMediaStore sharedStore].currentMediaType == MediaTypePhoto) {
            [self closePhotoTakerController];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
        
    } else if (controller == self.photoTakerController) {
        [self setupPhotoTakerController];
        
        [self.view layoutIfNeeded];
        
        if ([RTCMediaStore sharedStore].currentMediaType == MediaTypeImage) {
            [self closeImagePickerController];
            
        } else {
            
        }
        
        [self.mediaContainerView addSubview:self.photoTakerController.view];
        self.photoTakerController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.mediaContainerViewHeightConstraint.constant = self.view.bounds.size.width;
            //   [self setConstraintsForPhotoTakerController];
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
      //  [self presentViewController:self.photoTakerController animated:YES completion:nil];
       // [self.mediaContainerView addSubview:self.photoTakerController.view];
        
       // [self setConstraintsForPhotoTakerController];

    }
    
    [controller didMoveToParentViewController:self];
}

- (void)setConstraintsForImagePickerViewController {
    if (![self.imagePickerViewController.view superview]) return;
    
    self.imagePickerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaContainerViewHeightConstraint.constant = self.imagePickerViewController.view.bounds.size.height;
    
    NSDictionary *nameMap = @{@"imagePickerView": self.imagePickerViewController.view,
                              };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imagePickerView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imagePickerView]-0-|" options:0 metrics:nil views:nameMap];
    
    [self.mediaContainerView addConstraints:horizontalConstraints];
    [self.mediaContainerView addConstraints:verticalConstraints];
    
}
- (void)setConstraintsForCollectionViewController {
    if (![self.collectionViewController.view superview]) return;
    
    self.collectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *nameMap = @{@"collectionView": self.collectionViewController.view,
                              };
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:nameMap];
    
    [self.controllerCollectionView addConstraints:horizontalConstraints];
    [self.controllerCollectionView addConstraints:verticalConstraints];
}

- (void)setConstraintsForPhotoTakerController {
    if (![self.collectionViewController.view superview]) return;
    
    self.photoTakerController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *nameMap = @{@"photoTakerView": self.photoTakerController.view,
                              };
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[photoTakerView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[photoTakerView]-0-|" options:0 metrics:nil views:nameMap];
    
    [self.controllerCollectionView addConstraints:horizontalConstraints];
    [self.controllerCollectionView addConstraints:verticalConstraints];
}

#pragma mark - IBActions

- (IBAction)sendMessages:(id)sender { // Нажатие кнопки
    
    if (![self.messageTextField.text isEqualToString:@""]) {
        [self.collectionViewController addMessageWithDate:[NSDate date] text:self.messageTextField.text];
        self.messageTextField.text = @"";
    }
    
    if (self.imageGalleryMediaButton.selected) {
        NSArray *uploadedImages = [[RTCMediaStore sharedStore] imageGalleryItems];
        
        if (uploadedImages.count) {
            for (int i = 0; i < uploadedImages.count; i++) {
                [self.collectionViewController addMessageWithDate:[NSDate date] media:uploadedImages[i]];
            }
        }
        
        [[RTCMediaStore sharedStore] cleanImageGallery];
        [self.imagePickerViewController updateScrollView];
        
        if (uploadedImages.count) {
            [self resetMediaButtonsAndMediaToolbarContainer];
        }
    }
    
    [self setSendButtonColor];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    if ([newString isEqualToString:@""]) {
        self.messageTextField.text = @"";
        [self setSendButtonColor];
    } else {
        [self setActiveSendButtonColor];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self setSendButtonColor];
    
    return YES;
}

#pragma mark - Text Send Button

- (void)setSendButtonColor {
    if ((self.imageGalleryMediaButton.selected && ([[RTCMediaStore sharedStore] imageGalleryItems].count > 0)) || ![self.messageTextField.text isEqualToString:@""]) {
        NSLog(@"Activate");
        [self setActiveSendButtonColor];
    } else {
        [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)setActiveSendButtonColor {
    [self.sendButton setTitleColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1] forState:UIControlStateNormal];
}

#pragma mark - Media Buttons

- (IBAction)openTakingPhotoContainer:(id)sender {
    [self pressMediaButton:sender];
}
- (IBAction)openPhotoGalleryContainer:(id)sender {
    [self pressMediaButton:sender];
}
- (IBAction)sendLocation:(id)sender {
    [self pressMediaButton:sender];
}

- (void)pressMediaButton:(UIButton *)sender {
    if (sender.selected) { // Если повторное нажатие на кнопку, то закрыть
        [self resetMediaButtonsAndMediaToolbarContainer];
    } else { // Иначе открыть
       // self.mediaContainerView.hidden = NO;
        
        NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
        
        for (int i = 0; i < mediaButtons.count; i++) {
            if ([mediaButtons[i] isKindOfClass:[UIButton class]] && (mediaButtons[i] != sender)) {
                ((UIButton *)mediaButtons[i]).alpha = 0.5;
                ((UIButton *)mediaButtons[i]).selected = NO;
            }
        }
        
        sender.selected = YES;
        sender.alpha = 1.0;
        
        if (sender == self.photoTakingMediaButton) {
            [RTCMediaStore sharedStore].currentMediaType = MediaTypePhoto;
            
            if (!self.photoTakerController) {
                self.photoTakerController = [[RTCPhotoTakerController alloc] init];
            }
            
            [self displayViewController:self.photoTakerController];
            
        } else if (sender == self.imageGalleryMediaButton) { // Add gallery view
            [RTCMediaStore sharedStore].currentMediaType = MediaTypeImage;
            
            if (!self.imagePickerViewController) {
                self.imagePickerViewController = [[RTCImagePickerViewController alloc] init];
            }
            
            [self displayViewController:self.imagePickerViewController];
            
        } else if (sender == self.locationMediaButton) {
            [RTCMediaStore sharedStore].currentMediaType = MediaTypeLocation;
        }
        
    }
}

- (void)resetMediaButtonsAndMediaToolbarContainer { // close media containers and unselect media buttons
    
    [RTCMediaStore sharedStore].currentMediaType = MediaTypeNone;
    
    NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
    
    for (int i = 0; i < mediaButtons.count; i++) {
        if ([mediaButtons[i] isKindOfClass:[UIButton class]]) {
            UIButton *mediaButton = (UIButton *)mediaButtons[i];
            
            mediaButton.alpha = 1;
            
            if (mediaButton.selected) {
                mediaButton.selected = NO;
                
                if (mediaButton == self.imageGalleryMediaButton) {
                    [self closeImagePickerController];
                } else if (mediaButton == self.photoTakingMediaButton) {
                    [self closePhotoTakerController];
                } else if (mediaButton == self.locationMediaButton) {
                
                }
            }
            
        }
    }
    
}

- (void)closeImagePickerController {

    [self setSendButtonColor];
    
    [self.imagePickerViewController.view removeFromSuperview];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.mediaContainerViewHeightConstraint.constant = 0;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
      //  self.mediaContainerView.hidden = YES;
    }];
}

#pragma mark - Photo Taker Controller

- (void)closePhotoTakerController {
    if (!self.photoTakerController) return;
    

    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.mediaContainerViewHeightConstraint.constant = 0;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.photoTakerController.view removeFromSuperview];
      //  self.mediaContainerView.hidden = YES;
        self.photoTakerController = nil;
    }];
}

- (void)setupPhotoTakerController {
    if (!self.photoTakerController) return;
    
    if ([RTCPhotoTakerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.photoTakerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.photoTakerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.photoTakerController.showsCameraControls = NO;
    
 //   UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
   // overlayView.backgroundColor = [UIColor whiteColor];
  //  self.photoTakerController.cameraOverlayView = overlayView;

    
  //  [self.mediaContainerViewHeightConstraint.constant =

}

@end