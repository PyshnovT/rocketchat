//
//  RTCMainViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTCMapViewController;

@interface RTCMainViewController : UIViewController 

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContainerViewHeightConstraint;

// Location

@property (strong, nonatomic) RTCMapViewController *mapViewController;

- (void)setSendButtonColor;

- (void)setPhotoTakerControllerFullScreenMode;
- (void)setPhotoTakerControllerShortScreenMode;

- (void)closeOpenedMediaContainerIfNeededWithCompletion:(void (^)())completion;

@end
