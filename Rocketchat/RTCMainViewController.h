//
//  RTCMainViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTCMainViewController : UIViewController 

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContainerViewHeightConstraint;


- (void)setSendButtonColor;

@end
