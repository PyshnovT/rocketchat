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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface RTCMainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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

@property (nonatomic, strong) IBOutlet UIView *photoPickerView;
@property (weak, nonatomic) IBOutlet UIScrollView *photoPickerScrollView;


@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerForKeyboardNotifications];

    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"RTCMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
    self.messageTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
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
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRotation:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
    }
    
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
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillChangeFrameNotification
                                                      object:nil];
        
    }
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

#pragma mark - Rotation

// Сделать нотификации для iOS 7


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self handleRotation:nil];
}

- (void)handleRotation:(NSNotification *)note {
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - IBActions

- (IBAction)sendTextMessage:(id)sender { // Нажатие кнопки
    // Надо будет подкорректировать эту функцию
    [self addMessageWithDate:[NSDate date] text:self.messageTextField.text media:nil];
    self.messageTextField.text = @"";
    
    [self.textSendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}


#pragma mark - Adding messages

- (void)addMessageWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media {
    if ((text && media) || (!text && !media) || [text isEqualToString:@""]) return;
    
    
    if (text) {
        [[RTCMessageStore sharedStore] createMessageWithDate:date text:text];
    } else if (media) {
        
    }
    
    [self.collectionView reloadData];
    
    [self scrollToNewestMessage];
    
}

- (void)scrollToNewestMessage {
    NSInteger itemsCount = [[RTCMessageStore sharedStore] allMessages].count;
    
    if (!itemsCount) return;
    
    NSIndexPath *indexPathForLastItem = [NSIndexPath indexPathForRow:itemsCount-1 inSection:0];

    CGFloat newMessageHeight =  UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? [((RTCMessageCollectionViewLayout *)self.collectionView.collectionViewLayout) sizeForMessageAtIndexPath:indexPathForLastItem].height : 0;

    
    CGFloat lastMessageBottomY = self.collectionView.contentSize.height + newMessageHeight;
    
    if (lastMessageBottomY > self.collectionView.bounds.size.height) {
        
        CGFloat yOffset = MAX(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
        
        [self.collectionView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    }
    
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


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[RTCMessageStore sharedStore] allMessages].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RTCMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    RTCMessage *message = [[[RTCMessageStore sharedStore] allMessages] objectAtIndex:indexPath.row];
    
  //  cell.backgroundColor = [UIColor colorWithRed:0.04 green:0.51 blue:0.99 alpha:1];
    cell.isMediaCell = message.media ? YES : NO;
    
    if (message.text) {
        
        cell.textLabel.text = message.text;
        
    } else if (message.media) {
        
    }
    
    return cell;
}


#pragma mark - <UICollectionViewDelegate>

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
        NSLog(@"Кнопка выбрана, закрыть");
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
            
            //self.mediaContainerView.translatesAutoresizingMaskIntoConstraints = NO;
            self.photoPickerView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.mediaContainerView addSubview:self.photoPickerView];
            
            
            CGFloat photoPickerViewHeigth = self.photoPickerView.bounds.size.height;
            self.mediaContainerViewHeightConstraint.constant = photoPickerViewHeigth;
            
            
            NSDictionary *nameMap = @{@"photoPickerView": self.photoPickerView,
                                      @"mediaContainerView": self.mediaContainerView
                                      };
            
            NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[photoPickerView]-0-|" options:0 metrics:nil views:nameMap];
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[photoPickerView]-0-|" options:0 metrics:nil views:nameMap];
            
            [self.mediaContainerView addConstraints:horizontalConstraints];
            [self.mediaContainerView addConstraints:verticalConstraints];

            
        } else if (sender == self.locationMediaButton) {

        }
        
    }
}

- (void)resetMediaButtonsAndMediaToolbarContainer {
    NSArray *mediaButtons = [self.mediaPickerToolbarView subviews];
    
    for (int i = 0; i < mediaButtons.count; i++) {
        if ([mediaButtons[i] isKindOfClass:[UIButton class]]) {
            ((UIButton *)mediaButtons[i]).alpha = 1;
            ((UIButton *)mediaButtons[i]).selected = NO;
        }
    }
    
    [self.photoPickerView removeFromSuperview];
    self.mediaContainerViewHeightConstraint.constant = 0;
    self.mediaContainerView.hidden = YES;
}

#pragma mark - Photo Picker

- (UIView *)photoPickerView {
    if (!_photoPickerView) {
        [[NSBundle mainBundle] loadNibNamed:@"RTCPhotoPickerView" owner:self options:nil];
    }
    
    return _photoPickerView;
}

- (IBAction)addPhotoFromGallery:(id)sender {
    NSLog(@"Add Photo!");
}


@end
