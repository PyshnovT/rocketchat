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

+ (instancetype)itemWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage {
    return [[self alloc] initWithImage:image thumbnailImage:thumbnailImage];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
        _thumbnailImage = [image scaleImageToFitWithSize:[image imageSizeToFitWidth:240]];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage {
    self = [super init];
    if (self) {
        _image = image;
        _thumbnailImage = thumbnailImage;
    }
    return self;
}


@end
