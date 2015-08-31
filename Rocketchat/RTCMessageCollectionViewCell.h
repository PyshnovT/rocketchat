//
//  RTCMessageCollectionViewCell.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;

@interface RTCMessageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UITextView *textLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic) BOOL isMediaCell;
@property (nonatomic, strong) CLLocation *location;

@end
