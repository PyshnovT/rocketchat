//
//  RTCImageLookerViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 01/09/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTCImageLookerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (instancetype)initWithImage:(UIImage *)image;

@end
