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

@interface RTCMainViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Bottom View
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;



@end

@implementation RTCMainViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [self.collectionView.collectionViewLayout class]);
    [self.collectionView registerClass:[RTCMessageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)sendTextMessage:(id)sender { // Нажатие кнопки
    [self addMessageWithDate:[NSDate date] text:self.messageTextField.text media:nil];
}


#pragma mark - Adding messages

- (void)addMessageWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media {
    if ((text && media) || (!text && !media)) return;
    
    
    if (text) {
        [[RTCMessageStore sharedStore] createMessageWithDate:date text:text];
    } else if (media) {
        
    }
    
   // NSLog(@"%@", [[RTCMessageStore sharedStore] allMessages]);
    
    [self.collectionView reloadData];
    
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
    
    cell.backgroundColor = [UIColor redColor];
    
    if (message.text) {
        cell.textLabel.text = message.text;
    } else if (message.media) {
        
    }
    
    return cell;
}


#pragma mark - <UICollectionViewDelegate>

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 30);
}

@end
