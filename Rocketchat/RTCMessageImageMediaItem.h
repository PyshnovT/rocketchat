//
//  RTCMessagePhotoMedia.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCMessageMedia.h"

@interface RTCMessageImageMediaItem : NSObject <RTCMessageMedia>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

+ (instancetype)itemWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image;


@end
