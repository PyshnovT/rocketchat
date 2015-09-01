//
//  RTCMainViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMainViewController.h"

#import "RTCTextToolbarView.h"

#import "RTCMessageStore.h"
#import "RTCMessage.h"

#import "RTCMediaStore.h"
#import "RTCMessageImageMediaItem.h"
#import "RTCMessageLocationMediaItem.h"

#import "RTCMessageCollectionViewLayout.h"
#import "RTCCollectionViewController.h"
#import "RTCMessageCollectionViewCell.h"

#import "RTCImagePickerViewController.h"

#import "RTCPhotoTakerController.h"

#import "RTCMapViewController.h"
#import "RTCImageLookerViewController.h"

#import "UIImage+Scale.h"

typedef enum {
    ImageViewPlaceholderPanDirectionLeft,
    ImageViewPlaceholderPanDirectionTop,
    ImageViewPlaceholderPanDirectionRight,
    ImageViewPlaceholderPanDirectionBottom,
    ImageViewPlaceholderPanDirectionNone
} ImageViewPlaceholderPanDirection;

@interface RTCMainViewController () <UITextFieldDelegate>

// Collection View

@property (weak, nonatomic) IBOutlet UIView *controllerCollectionView;
@property (strong, nonatomic) RTCCollectionViewController *collectionViewController;

// Views

@property (weak, nonatomic) IBOutlet UIView *mediaContainerView;
@property (weak, nonatomic) IBOutlet UIView *mediaPickerToolbarView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// .ViewController Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewToMediaPickerToolbarViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaPickerToolbarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContainerViewHeightConstraint;

// Media Buttons

@property (weak, nonatomic) IBOutlet UIButton *photoTakingMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *imageGalleryMediaButton;
@property (weak, nonatomic) IBOutlet UIButton *locationMediaButton;

// Image Picker

@property (strong, nonatomic) RTCImagePickerViewController *imagePickerViewController;

// Photo Taker

@property (strong, nonatomic) RTCPhotoTakerController *photoTakerController;

// Image Looker

@property (strong, nonatomic) RTCImageLookerViewController *imageLookerController;
@property (strong, nonatomic) UIImageView *imageViewPlaceholder;

//@property (nonatomic) CGRect imageViewPlaceholderCellRect;
@property (strong, nonatomic) NSIndexPath *indexPathForViewingCell;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

// Keyboard

@property (nonatomic) BOOL isKeyboardShown;

@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageViewPlaceholder = nil;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImageViewPlaceholder:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.isKeyboardShown = NO;
    
    RTCMessageCollectionViewLayout *messageLayout = [[RTCMessageCollectionViewLayout alloc] init];
    self.collectionViewController = [[RTCCollectionViewController alloc]
                                     initWithCollectionViewLayout:messageLayout];
    
    [self displayViewController:self.collectionViewController];
    self.messageTextField.delegate = self;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setPhotoPickerControllerAbilityForViewSize:self.view.bounds.size];
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
    self.isKeyboardShown = YES;
    [self updateConstraintsForKeyboardNotification:note];
}


- (void)keyboardWillBeHidden:(NSNotification *)note {
    self.isKeyboardShown = YES;
    [self updateConstraintsForKeyboardNotification:note];
}

- (void)updateConstraintsForKeyboardNotification:(NSNotification*)note {
    NSDictionary *userInfo = note.userInfo;
    NSLog(@"%@", userInfo);
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    float keyboardHeight = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY([self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil]);
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^{
        
        
        self.inputToolbarViewToMediaPickerToolbarViewConstraint.constant = MAX(keyboardHeight - self.mediaPickerToolbarViewHeightConstraint.constant - self.mediaContainerViewHeightConstraint.constant, 0);
        
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Notifications

- (void)registerForRotationNotifications {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRotationNotification:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

- (void)deregisterForRotationNotifications {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate {
    CGSize viewSize = self.view.bounds.size;
    
    if (viewSize.width > viewSize.height) {
        return YES;
    } else {
        if ([RTCMediaStore sharedStore].currentMediaType == MediaTypePhoto) {
            return NO;
        }
    }
    
    return YES;;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleRotationNotification:nil forSize:size];
}

- (void)handleRotationNotification:(NSNotification *)note {
    [self handleRotationNotification:note forSize:CGSizeZero];
}

- (void)handleRotationNotification:(NSNotification *)note forSize:(CGSize)size {
    
    [self setPhotoPickerControllerAbilityForViewSize:size]; // такс, при iOS 7 тут не будет размера
    
    if (size.width > size.height) {
        self.statusBarHeightConstraint.constant = 0;
    } else {
        self.statusBarHeightConstraint.constant = 21;
    }
}

- (void)setPhotoPickerControllerAbilityForViewSize:(CGSize)viewSize {
    if (viewSize.width > viewSize.height) {
        self.photoTakingMediaButton.enabled = NO;
    } else {
        self.photoTakingMediaButton.enabled = YES;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect newImageViewFrame = [self imageViewPlaceholderFrameForWidth:self.view.bounds.size.width];
    self.imageViewPlaceholder.frame = newImageViewFrame;
}

#pragma mark - Displaying Controllers

- (void)displayViewController:(UIViewController *)controller {
    
    [self addChildViewController:controller];
    
    if (controller == self.collectionViewController) {
        
        self.collectionViewController.mvc = self;
        [self.controllerCollectionView addSubview:controller.view];
        [self setConstraintsForCollectionViewController];
        
    } else if (controller == self.imagePickerViewController) {
        [RTCMediaStore sharedStore].currentMediaType = MediaTypeImage;
        
        
        if ([[RTCMediaStore sharedStore] imageGalleryItems].count) {
            [self setActiveSendButtonColor];
        }
        
        self.imagePickerViewController.mvc = self;
        
        [self.view layoutIfNeeded];
        
        [self.mediaContainerView addSubview:self.imagePickerViewController.view];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self setConstraintsForImagePickerViewController];
            [self.view layoutIfNeeded];
        }];
        
    } else if (controller == self.photoTakerController) { // здесь стоит плейсхолдер
        [RTCMediaStore sharedStore].currentMediaType = MediaTypePhoto;
        
        self.photoTakerController.mvc = self;
        
       // [self setupPhotoTakerController];
        
        [self.view layoutIfNeeded];
        
        
        [UIView animateWithDuration:0.2 animations:^{
            self.mediaContainerViewHeightConstraint.constant = self.photoTakerController.view.bounds.size.width;

            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self setPhotoTakerControllerShortScreenMode];
            [self.view addSubview:self.photoTakerController.view];
        }];
        
    } else if (controller == self.mapViewController) {
        
        [RTCMediaStore sharedStore].currentMediaType = MediaTypeLocation;
        self.mapViewController.mvc = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];

        
        [self presentViewController:navController animated:YES completion:nil];
        
    } else if (controller == self.imageLookerController) {
        
        self.imageLookerController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.imageLookerController.view.alpha = 0.0;
        
        [self.view addSubview:self.imageLookerController.view];
        
        [self.view addSubview:self.imageViewPlaceholder];
        NSLog(@"%@", self.imageViewPlaceholder);
        

        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.imageLookerController.view.alpha = 1.0;
            self.imageViewPlaceholder.frame = [self imageViewPlaceholderFrameForWidth:self.view.bounds.size.width];
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    [controller didMoveToParentViewController:self];
}

- (CGRect)imageViewPlaceholderFrameForWidth:(CGFloat)width {
    CGSize newImageViewSize = [self.imageViewPlaceholder.image imageSizeToFitWidth:width];
    
    CGFloat x = 0;
    CGFloat y = self.view.bounds.size.height * 0.5 - newImageViewSize.height / 2.0;
    
    return CGRectMake(x, y, newImageViewSize.width, newImageViewSize.height);
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




#pragma mark - IBActions

- (IBAction)sendMessages:(id)sender {
    
    if (![self.messageTextField.text isEqualToString:@""]) {
        [self.collectionViewController addMessageWithDate:[NSDate date] text:self.messageTextField.text];
        self.messageTextField.text = @"";
    }
    
    if ([RTCMediaStore sharedStore].currentMediaType == MediaTypeImage) {
        NSArray *uploadedImages = [[RTCMediaStore sharedStore] imageGalleryItems];
        
        if (uploadedImages.count) {
            [self closeOpenedMediaContainerIfNeededWithCompletion:nil];
        }
        
        if (uploadedImages.count) {
            for (int i = 0; i < uploadedImages.count; i++) {
                [self.collectionViewController addMessageWithDate:[NSDate date] media:uploadedImages[i]];
            }
        }
        
        [[RTCMediaStore sharedStore] cleanImageGallery];
        [self.imagePickerViewController updateScrollView];
        
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
    if (([RTCMediaStore sharedStore].currentMediaType == MediaTypeImage && ([[RTCMediaStore sharedStore] imageGalleryItems].count > 0)) || ![self.messageTextField.text isEqualToString:@""]) {
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
        [self closeOpenedMediaContainerIfNeededWithCompletion:nil];
    } else { // Иначе закрыть старый контейнер, если он был, и открыть новый
        
        void (^onCompletion)() = ^void() {
            NSLog(@"Completion block playing!");
            
            sender.selected = YES;
            sender.alpha = 1.0;
            
            NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
            
            for (int i = 0; i < mediaButtons.count; i++) {
                if ([mediaButtons[i] isKindOfClass:[UIButton class]] && (mediaButtons[i] != sender)) {
                    ((UIButton *)mediaButtons[i]).alpha = 0.5;
                    ((UIButton *)mediaButtons[i]).selected = NO;
                }
            }
            
            if (sender == self.photoTakingMediaButton) {
                NSLog(@"First");
                if (!self.photoTakerController) {
                    NSLog(@"Creating new photo picker");
                    self.photoTakerController = [[RTCPhotoTakerController alloc] init];
                }
                NSLog(@"Second");
                [self displayViewController:self.photoTakerController];
                
            } else if (sender == self.imageGalleryMediaButton) { // Add gallery view
                
                if (!self.imagePickerViewController) {
                    self.imagePickerViewController = [[RTCImagePickerViewController alloc] init];
                }
                
                [self displayViewController:self.imagePickerViewController];
                
            } else if (sender == self.locationMediaButton) {
                
                if (!self.mapViewController) {
                    self.mapViewController = [[RTCMapViewController alloc] initForSendingLocation:YES];
                }
                
                [self displayViewController:self.mapViewController];
                
            }
            
        };
        
        [self closeOpenedMediaContainerIfNeededWithCompletion:onCompletion];
        
    }
}

#pragma mark - Closing Containers

- (void)closeOpenedMediaContainerIfNeededWithCompletion:(void (^)())completion { // close media containers and unselect media buttons
    
    [self cleanMediaButtons];
    
    MediaType currentMediaOpened = [RTCMediaStore sharedStore].currentMediaType;
    
    [RTCMediaStore sharedStore].currentMediaType = MediaTypeNone;


    
    if (currentMediaOpened == MediaTypeNone) {
        
        if (completion) {
            completion();
        }
        
    } else if (currentMediaOpened == MediaTypeImage) {
        [self closeImagePickerControllerWithCompletion:completion];
    } else if (currentMediaOpened == MediaTypePhoto) {
        [self closePhotoTakerControllerWithCompletion:completion];
    } else if (currentMediaOpened == MediaTypeLocation) {
        [self closeMapViewControllerWithCompletion:completion];
    }
    
    if (self.isKeyboardShown) {
        [self.messageTextField resignFirstResponder];
    }
}

- (void)cleanMediaButtons {
    NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
    
    for (int i = 0; i < mediaButtons.count; i++) {
        if ([mediaButtons[i] isKindOfClass:[UIButton class]]) {
            UIButton *mediaButton = (UIButton *)mediaButtons[i];
            
            mediaButton.alpha = 1;
            mediaButton.selected = NO;
            
        }
    }
}

- (void)closeImagePickerControllerWithCompletion:(void (^)())completion {
    
    [self setSendButtonColor];
    
    [self.view layoutIfNeeded];
    
    [self.imagePickerViewController.view removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mediaContainerViewHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}



- (void)closePhotoTakerControllerWithCompletion:(void (^)())completion { // здесь стоит плейсхолдер
    if (!self.photoTakerController) return;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.mediaContainerViewHeightConstraint.constant = 0;

        self.photoTakerController.view.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width);
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.photoTakerController.view removeFromSuperview];
        self.photoTakerController = nil;
        
        
        if (completion) {
            completion();
        }
    }];
}

- (void)closeMapViewControllerWithCompletion:(void (^)())completion {
    RTCMessageLocationMediaItem *locationItem = [[RTCMediaStore sharedStore] locationSnapshot];
    
    if (locationItem) {
        [self.collectionViewController addMessageWithDate:[NSDate date] media:locationItem];
        [[RTCMediaStore sharedStore] cleanLocationSnapshot];
    }

    
    self.mapViewController = nil;
    NSLog(@"%@", self.mapViewController);
    
    if (completion) {
        completion();
    }
}

- (void)closeImageLookerController {
    [UIView animateWithDuration:0.3 animations:^{
        self.imageLookerController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.imageLookerController.view removeFromSuperview];
        self.imageLookerController = nil;
    }];
}

#pragma mark - Photo Taker Controller

- (void)sendTakenPhoto {
    RTCMessageImageMediaItem *photoItem = [[RTCMediaStore sharedStore] takenPhoto];
    
    if (photoItem) {

        [self.collectionViewController addMessageWithDate:[NSDate date] media:photoItem];
        
    }
}

- (void)setPhotoTakerControllerFullScreenMode {
    self.photoTakerController.screenMode = PhotoScreenModeFull;
    
    UIView *photoTakerView = self.photoTakerController.view;
    
    photoTakerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)setPhotoTakerControllerShortScreenMode {
    self.photoTakerController.screenMode = PhotoScreenModeShort;
    
    UIView *photoTakerView = self.photoTakerController.view;
    
    photoTakerView.frame = CGRectMake(0, self.view.bounds.size.height - self.view.bounds.size.width, self.view.bounds.size.width, self.view.bounds.size.width);
}

#pragma mark - Image Viewing

- (void)presentImageLookerControllerForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect fromRect = [self frameForCellAtIndexPath:indexPath];
    
    self.indexPathForViewingCell = indexPath;
    RTCMessageCollectionViewCell *cell = (RTCMessageCollectionViewCell *)[self.collectionViewController.collectionView cellForItemAtIndexPath:indexPath];
    cell.imageView.hidden = YES;
    
    NSInteger row = indexPath.row;
    
    RTCMessage *messageForCell = [[[RTCMessageStore sharedStore] allMessages] objectAtIndex:row];
    UIImage *fullImage = ((RTCMessageImageMediaItem *)messageForCell.media).image;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:fromRect];
    imageView.image = fullImage;
    imageView.clipsToBounds = YES;
    
    self.imageViewPlaceholder = imageView;
    
    self.imageLookerController = [[RTCImageLookerViewController alloc] initWithImage:fullImage];
    [self displayViewController:self.imageLookerController];
    
}

- (void)moveImageViewPlaceholder:(UIPanGestureRecognizer *)gr {
    if (!self.imageViewPlaceholder) return;
    
    static CGPoint startOrigin;
    static ImageViewPlaceholderPanDirection direction;
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint startVelocity = [gr velocityInView:self.view];
        startOrigin = self.view.frame.origin;
        
        direction = [self imageViewPlaceholderDirectionWithVelocity:startVelocity andOrigin:startOrigin];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if ((direction == ImageViewPlaceholderPanDirectionBottom) || (direction == ImageViewPlaceholderPanDirectionTop) ) {
            
            [UIView animateWithDuration:0.2 animations:^{
                self.imageLookerController.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.imageLookerController removeFromParentViewController];
                self.imageLookerController = nil;
            }];

            
            CGPoint translation = [gr translationInView:self.view];
            
            float newX = self.imageViewPlaceholder.frame.origin.x + translation.x;
            float newY = self.imageViewPlaceholder.frame.origin.y + translation.y;
            
            self.imageViewPlaceholder.frame = CGRectMake(newX, newY, self.imageViewPlaceholder.bounds.size.width, self.imageViewPlaceholder.bounds.size.height);
            
            [gr setTranslation:CGPointZero inView:self.view];
        }
    } else if ((gr.state == UIGestureRecognizerStateEnded) || (gr.state == UIGestureRecognizerStateEnded)) {
        
        if ((direction == ImageViewPlaceholderPanDirectionBottom) || (direction == ImageViewPlaceholderPanDirectionTop) ) {
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.fromValue = [NSNumber numberWithFloat:0.0];
            animation.toValue = [NSNumber numberWithFloat:20.0];
            animation.duration = 0.2;
            
            [self.imageViewPlaceholder.layer addAnimation:animation forKey:@"cornerRadius"];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.imageViewPlaceholder.frame = [self frameForCellAtIndexPath:self.indexPathForViewingCell];
            } completion:^(BOOL finished) {
                
                self.imageLookerController = nil; // ну чтоб уж точно
                
                RTCMessageCollectionViewCell *cell = (RTCMessageCollectionViewCell *)[self.collectionViewController.collectionView cellForItemAtIndexPath:self.indexPathForViewingCell];
                self.indexPathForViewingCell = nil;
                cell.imageView.hidden = NO;
                
                [self.imageViewPlaceholder removeFromSuperview];
                self.imageViewPlaceholder = nil;
            }];
        }
        
    }
}

- (ImageViewPlaceholderPanDirection)imageViewPlaceholderDirectionWithVelocity:(CGPoint)velocity andOrigin:(CGPoint)origin {
    if (ABS(velocity.x) > ABS(velocity.y)) { // двигалось либо вправо, либо влево
        float newX = velocity.x + origin.x;
        
        if (newX > origin.x) { // вправо
            return ImageViewPlaceholderPanDirectionRight;
        } else {
            return ImageViewPlaceholderPanDirectionLeft;
        }
        
    } else if (ABS(velocity.x) < ABS(velocity.y)) { // двигалось либо вверх, либо вниз
        float newY = velocity.y + origin.y;
        
        if (newY > origin.y) { // вниз
            return ImageViewPlaceholderPanDirectionBottom;
        } else { // вверх
            return ImageViewPlaceholderPanDirectionTop;
        }
    } else {
        
        return ImageViewPlaceholderPanDirectionNone;
    }
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath {
    CGRect rectInCollectionView = [self.collectionViewController.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGRect rectInSuperview = [self.collectionViewController.collectionView convertRect:rectInCollectionView toView:self.view];
    
    return rectInSuperview;
}

@end