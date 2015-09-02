//
//  RTCMessageLocationMedia.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCMessageMedia.h"

@class CLLocation;

@interface RTCMessageLocationMediaItem : NSObject <RTCMessageMedia>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) CLLocation *location;

+ (instancetype)itemWithImage:(UIImage *)image andLocation:(CLLocation *)location;
- (instancetype)initWithImage:(UIImage *)image andLocation:(CLLocation *)location;

+ (instancetype)itemWithLocation:(CLLocation *)location andThumbnailImage:(UIImage *)thumbnailImage;
- (instancetype)initWithLocation:(CLLocation *)location andThumbnailImage:(UIImage *)thumbnailImage;


@end
