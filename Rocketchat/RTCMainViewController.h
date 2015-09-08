//
//  RTCMainViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"

@class RTCMapViewController;

@interface RTCMainViewController : UIViewController 

@property (strong, nonatomic) RTCMapViewController *mapViewController;
@property (weak, nonatomic) IBOutlet SAMTextView *messageTextView;

@property (nonatomic) NSInteger skip;
@property (nonatomic) BOOL isLoadingParseData;


- (void)setSendButtonColor;

// Photo taker methods

- (void)setPhotoTakerControllerFullScreenMode;
- (void)setPhotoTakerControllerShortScreenMode;
- (void)sendTakenPhoto;

// Image Viewing

- (void)presentImageLookerControllerForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)closeImageLookerController;

// Closing Media Containers

- (void)closeOpenedMediaContainerIfNeededWithCompletion:(void (^)())completion;

- (void)showSavingImageView;

// Parse

- (void)getParseDataWithSkip:(NSInteger)skip;


@end
