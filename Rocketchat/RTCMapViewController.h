//
//  RTCMapViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 31/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class CLLocation;
@class RTCMainViewController;

@interface RTCMapViewController : UIViewController

@property (weak, nonatomic) RTCMainViewController *mvc;
@property (strong, nonatomic) CLLocation *sentLocation;

- (instancetype)initForSendingLocation:(BOOL)isForSending;

@end
