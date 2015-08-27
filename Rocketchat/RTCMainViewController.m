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

/*
typedef enum {
    ButtonPhoto,
    ButtonGallery,
    ButtonLocation
} ButtonType;
*/
 
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
    
}

- (void)keyboardWillBeShown:(NSNotification *)note {
    [self updateConstraintsForKeyboard:note];
    [self scrollToNewestMessage];
}

- (void)keyboardWillBeHidden:(NSNotification *)note {
    [self updateConstraintsForKeyboard:note];
}

- (void)updateConstraintsForKeyboard:(NSNotification*)note {
    NSDictionary *userInfo = note.userInfo;
    NSLog(@"%@", userInfo);
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;

    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    float keyboardHeight = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY([self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil]);
    
    NSLog(@"%f", keyboardHeight);
    
    [self.view layoutIfNeeded];
    

    
    [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^{

        self.inputToolbarViewToMediaPickerToolbarViewConstraint.constant = MAX(keyboardHeight - self.mediaPickerToolbarViewHeightConstraint.constant, 0);

        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Rotation

// Сделать нотификации для iOS 7

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
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

    CGFloat newMessageHeight = [((RTCMessageCollectionViewLayout *)self.collectionView.collectionViewLayout) sizeForMessageAtIndexPath:indexPathForLastItem].height;
    
    CGFloat lastMessageBottomY = self.collectionView.contentSize.height + newMessageHeight;
    
    if (lastMessageBottomY > self.collectionView.bounds.size.height) {
        
        CGFloat yOffset = MAX(0, self.collectionView.contentSize.height + newMessageHeight - self.collectionView.bounds.size.height);
        
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
            
            [self.mediaContainerView addSubview:self.photoPickerView];
            
            CGFloat photoPickerViewHeigth = self.photoPickerView.bounds.size.height;
            self.mediaContainerViewHeightConstraint.constant = photoPickerViewHeigth;
            
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
    
    self.mediaContainerViewHeightConstraint.constant = 0;
    self.mediaContainerView.hidden = YES;
}

#pragma mark - Photo Picker

- (UIView *)photoPickerView {
    if (!_photoPickerView) {
        [[NSBundle mainBundle] loadNibNamed:@"RTCPhotoPickerView" owner:self options:nil];
        
        
      //  self.mediaContainerView addCon
    }
    
    return _photoPickerView;
}

- (IBAction)addPhotoFromGallery:(id)sender {
    NSLog(@"Add Photo!");
}


@end
