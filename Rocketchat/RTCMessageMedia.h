//
//  RTCMessageMedia.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTCMessageMedia <NSObject>

@required

@property (nonatomic, strong) UIImage *image;

@optional

@property (nonatomic, strong) UIImage *thumbnailImage;

+ (instancetype)itemWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image;

@end
