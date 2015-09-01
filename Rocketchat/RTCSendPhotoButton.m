//
//  RTCSendPhotoButton.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 31/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCSendPhotoButton.h"

@implementation RTCSendPhotoButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = self.bounds.size.width / 2.0;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end
