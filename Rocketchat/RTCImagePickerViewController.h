//
//  RTCImagePickerViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 28/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTCMainViewController;

@interface RTCImagePickerViewController : UIViewController

@property (nonatomic, weak) RTCMainViewController *mvc;

- (void)updateScrollView;

@end
