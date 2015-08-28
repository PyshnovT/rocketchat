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

@interface RTCMainViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *controllerCollectionView;
@property (strong, nonatomic) RTCCollectionViewController *collectionViewController;
@property (weak, nonatomic) IBOutlet UIView *mediaContainerView;
@property (weak, nonatomic) IBOutlet UIView *mediaPickerToolbarView;


@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *textSendButton;

// .ViewController xib

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewToMediaPickerToolbarViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaPickerToolbarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContainerViewHeightConstraint;


// Media Buttons


@property (weak, nonatomic) IBOutlet UIButton *photoTakingMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *photoGalleryMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *locationMediaButton;

// PhotoPicker .xib

@property (nonatomic, strong) IBOutlet UIView *imagePickerView;
@property (weak, nonatomic) IBOutlet UIScrollView *imagePickerScrollView;


@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    RTCMessageCollectionViewLayout *messageLayout = [[RTCMessageCollectionViewLayout alloc] init];
    self.collectionViewController = [[RTCCollectionViewController alloc] initWithCollectionViewLayout:messageLayout];
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

#pragma mark - Collection View Controller

- (void)displayViewController:(UIViewController *)controller {
    [self addChildViewController:controller];
    
    if (controller == self.collectionViewController) {
    
        [self.controllerCollectionView addSubview:controller.view];
        [self setConstraintsForCollectionViewController];
        
    }
    [controller didMoveToParentViewController:self];
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

#pragma mark - IBActions

- (IBAction)sendTextMessage:(id)sender { // Нажатие кнопки
    // Надо будет подкорректировать эту функцию
    [self.collectionViewController addMessageWithDate:[NSDate date] text:self.messageTextField.text media:nil];
    self.messageTextField.text = @"";
    
    [self.textSendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    if ([newString isEqualToString:@""]) {
        [self.textSendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        [self.textSendButton setTitleColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1] forState:UIControlStateNormal];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.textSendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    return YES;
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
    if (sender.selected) { // Если уже был выбран, то закрыть
        [self resetMediaButtonsAndMediaToolbarContainer];
    } else {
        self.mediaContainerView.hidden = NO;
        
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

        } else if (sender == self.photoGalleryMediaButton) { // Add gallery view
            
            [self addPhotoPickerView];
            
        } else if (sender == self.locationMediaButton) {

        }
        
    }
}

- (void)resetMediaButtonsAndMediaToolbarContainer {
    NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
    
    for (int i = 0; i < mediaButtons.count; i++) {
        if ([mediaButtons[i] isKindOfClass:[UIButton class]]) {
            UIButton *mediaButton = (UIButton *)mediaButtons[i];
            
            mediaButton.alpha = 1;
            
            if (mediaButton.selected) {
                NSLog(@"HERE!");
                [self.photoPickerView removeFromSuperview];
                self.mediaContainerViewHeightConstraint.constant = 0;
                self.mediaContainerView.hidden = YES;
            }
            
            mediaButton.selected = NO;
        }
    }

}

- (void)addPhotoPickerView {
    self.photoPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaContainerView addSubview:self.photoPickerView];
    
    CGFloat photoPickerViewHeigth = self.photoPickerView.bounds.size.height;
    self.mediaContainerViewHeightConstraint.constant = photoPickerViewHeigth;
    
    
    NSDictionary *nameMap = @{@"photoPickerView": self.photoPickerView,
                              };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[photoPickerView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[photoPickerView]-0-|" options:0 metrics:nil views:nameMap];
    
    [self.mediaContainerView addConstraints:horizontalConstraints];
    [self.mediaContainerView addConstraints:verticalConstraints];
}

#pragma mark - Photo Picker

- (UIView *)photoPickerView {
    if (!_imagePickerView) {
        [[NSBundle mainBundle] loadNibNamed:@"RTCImagePickerView" owner:self options:nil];
        self.imagePickerScrollView.alwaysBounceHorizontal = YES;
    }
    
    return _imagePickerView;
}

- (IBAction)addPhotoFromGallery:(id)sender {
    NSLog(@"Add Photo!");
    
    if ([[RTCMediaStore sharedStore] imageGalleryItems].count == 8) {
        NSLog(@"No more photos");
        
        
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

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:originalImage];
    
    CGFloat sideLength = self.imagePickerScrollView.bounds.size.height;
    CGFloat interImageY = 5;
    
    NSInteger uploadedImages = [[RTCMediaStore sharedStore] imageGalleryItems].count;

    CGFloat x = uploadedImages * (interImageY + sideLength);
    imageView.frame = CGRectMake(x, 0, sideLength, sideLength);
    
    [[RTCMediaStore sharedStore] addImageFromGallery:originalImage];
    
    self.imagePickerScrollView.contentSize = CGSizeMake([[RTCMediaStore sharedStore] imageGalleryItems].count * (interImageY + sideLength), sideLength);
    [self.imagePickerScrollView addSubview:imageView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
