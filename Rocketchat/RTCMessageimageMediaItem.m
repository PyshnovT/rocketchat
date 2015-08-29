//
//  RTCMessagePhotoMedia.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageImageMediaItem.h"
#import "UIImage+Scale.h"

@implementation RTCMessageImageMediaItem

+ (instancetype)itemWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
        _thumbnailImage = [image scaleImageToFillWidth:240]; // 240?
    }
    return self;
}


@end
