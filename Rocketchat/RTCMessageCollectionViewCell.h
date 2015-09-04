//
//  RTCMessageCollectionViewCell.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCMessage.h"

@class CLLocation;

@interface RTCMessageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *ticketView;
@property (nonatomic, weak) IBOutlet UITextView *textLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;

@property (nonatomic) BOOL isMediaCell;
@property (nonatomic, strong) CLLocation *location;

@end
