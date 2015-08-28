//
//  RTCMessagePhotoMedia.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageImageMediaItem.h"

@implementation RTCMessageImageMediaItem

+ (instancetype)itemWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}


@end
