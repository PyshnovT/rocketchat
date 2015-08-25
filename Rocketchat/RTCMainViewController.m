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

@interface RTCMainViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Bottom View
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTollbarViewConstraint;


@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerForKeyboardNotifications];

    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"RTCMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
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
}

- (void)keyboardWillBeHidden:(NSNotification *)note {
    [self updateConstraintsForKeyboard:note];
}

- (void)updateConstraintsForKeyboard:(NSNotification*)note {
    NSDictionary *userInfo = note.userInfo;
    NSLog(@"%@", userInfo);
    
    NSInteger animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;

    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    float keyboardHeight = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY([self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil]);
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        self.bottomTollbarViewConstraint.constant = keyboardHeight;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Rotation

// Сделать нотификации для iOS 7

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
   // self.collectionView.la
}

#pragma mark - IBActions

- (IBAction)sendTextMessage:(id)sender { // Нажатие кнопки
    // Надо будет подкорректировать эту функцию
    [self addMessageWithDate:[NSDate date] text:self.messageTextField.text media:nil];
    self.messageTextField.text = @"";
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
    //CGFloat bottomInset =((RTCMessageCollectionViewLayout *)self.collectionView.collectionViewLayout).collectionViewInsets.bottom;
    NSInteger itemsCount = [[RTCMessageStore sharedStore] allMessages].count;
    
    NSIndexPath *indexPathForLastItem = [NSIndexPath indexPathForRow:itemsCount-1 inSection:0];
    CGFloat newMessageHeight = [((RTCMessageCollectionViewLayout *)self.collectionView.collectionViewLayout) sizeForMessageAtIndexPath:indexPathForLastItem].height;
    
    CGFloat lastMessageBottomY = self.collectionView.contentSize.height + newMessageHeight;
    
    if (lastMessageBottomY > self.collectionView.bounds.size.height) {
        

        
        CGFloat yOffset = MAX(0, self.collectionView.contentSize.height + newMessageHeight - self.collectionView.bounds.size.height); //MIN([self.collectionView.collectionViewLayout collectionViewContentSize].height, );
        
        //NSLog(@"%f", self.collectionView.contentSize.height);
        
        [self.collectionView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    }
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


@end
