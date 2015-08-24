//
//  RTCMessageCollectionViewCell.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageCollectionViewCell.h"

@interface RTCMessageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bubbleView;

@end

@implementation RTCMessageCollectionViewCell

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupCell];
}

- (void)setupCell {
    self.bubbleView.layer.cornerRadius = 20;
    self.textLabel.backgroundColor = self.backgroundColor;
}

- (void)prepareForReuse {
    self.textLabel.text = nil;
}



@end
