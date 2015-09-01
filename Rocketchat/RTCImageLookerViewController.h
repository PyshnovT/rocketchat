//
//  RTCImageLookerViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 01/09/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTCMainViewController;

@interface RTCImageLookerViewController : UIViewController

@property (nonatomic) BOOL isSaving;

@property (nonatomic, weak) RTCMainViewController *mvc;

- (instancetype)initWithImage:(UIImage *)image;

@end
