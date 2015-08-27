//
//  RTCCollectionViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 27/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCCollectionViewController.h"
#import "RTCMessageStore.h"
#import "RTCMessageCollectionViewCell.h"
#import "RTCMessage.h"
#import "RTCMessageCollectionViewLayout.h"

@interface RTCCollectionViewController ()

@end

@implementation RTCCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"RTCMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForRotationNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self deregisterForRotationNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void)registerForRotationNotifications {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRotation:)
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self handleRotation:nil];
}

- (void)handleRotation:(NSNotification *)note {
    [self.collectionView.collectionViewLayout invalidateLayout];
    //[self scrollToNewestMessage];
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
    [self.collectionView.collectionViewLayout prepareLayout];

    if (self.collectionViewLayout.collectionViewContentSize.height > self.collectionView.bounds.size.height) {
        
        CGFloat yOffset = MAX(0, self.collectionViewLayout.collectionViewContentSize.height - self.collectionView.bounds.size.height);
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

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
