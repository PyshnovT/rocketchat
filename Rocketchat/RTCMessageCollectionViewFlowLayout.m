//
//  RTCMessageCollectionViewFlowLayout.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageCollectionViewFlowLayout.h"

@implementation RTCMessageCollectionViewFlowLayout 

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupLayout];
}

- (void)setupLayout {
    self.minimumInteritemSpacing = 10000;
    self.minimumLineSpacing = 20;
}

@end
