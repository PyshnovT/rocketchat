//
//  RTCMessageLocationMedia.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageLocationMediaItem.h"

#import <MapKit/MapKit.h>

#import "UIImage+Scale.h"

@implementation RTCMessageLocationMediaItem

+ (instancetype)itemWithImage:(UIImage *)image andLocation:(CLLocation *)location {
    return [[self alloc] initWithImage:image andLocation:location];
}

+ (instancetype)itemWithLocation:(CLLocation *)location andThumbnailImage:(UIImage *)thumbnailImage {
    return [[self alloc] initWithLocation:location andThumbnailImage:thumbnailImage];
}

- (instancetype)initWithImage:(UIImage *)image andLocation:(CLLocation *)location {
    self = [super init];
    if (self) {
        _image = image;
        _thumbnailImage = [image scaleImageToFitWithSize:[image imageSizeToFitWidth:240]];
        _location = location;
    }
    return self;
}

- (instancetype)initWithLocation:(CLLocation *)location andThumbnailImage:(UIImage *)thumbnailImage {
    self = [super init];
    if (self) {
        _image = thumbnailImage;
        _thumbnailImage = thumbnailImage;
        _location = location;
    }
    return self;
}

@end
